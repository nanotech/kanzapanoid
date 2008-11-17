#!/usr/bin/ruby
# Basically, the tutorial game taken to a jump'n'run perspective.

# Shows how to
#  * implement jumping/gravity
#  * implement scrolling
#  * implement a simple tile-based map
#  * load levels from primitive text files

# Some exercises, starting at the real basics:
#  0) understand the existing code!
# As shown in the tutorial:
#  1) change it use Gosu's Z-ordering
#  2) add gamepad support
#  3) add a score as in the tutorial game
#  4) similarly, add sound effects for various events
# Exploring this game's code and Gosu:
#  5) make the player wider, so he doesn't fall off edges as easily
#  6) add background music (check if playing in Window#update to implement 
#     looping)
#  7) implement parallax scrolling for the star background!
# Getting tricky:
#  8) optimize Map#draw so only tiles on screen are drawn (needs modulo, a pen
#     and paper to figure out)
#  9) add loading of next level when all gems are collected
# ...Enemies, a more sophisticated object system, weapons, title and credits
# screens...

begin
	# In case you use Gosu via rubygems.
	require 'rubygems'
rescue LoadError
	# In case you don't.
end

require 'gosu'
include Gosu

require 'chipmunk'

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480
TILE_SIZE = 50
SUBSTEPS = 10

# Convenience method for converting from radians to a Vec2 vector.
class Numeric
	def radians_to_vec2
		CP::Vec2.new(Math::cos(self), Math::sin(self))
	end
end

module Tiles
	Grass = 0
	Earth = 1
end

# Layering of sprites
module ZOrder
	Background, Tiles, Items, Player, UI = *0..5
end

class CollectibleGem
	attr_reader :shape

	def initialize(image, shape, vect)
		@image = image

		@shape = shape
		@shape.body.p = vect
		@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
		@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen
	end

	def draw(screen_x, screen_y)
		# Draw, slowly rotating
		@image.draw_rot(@shape.body.p.x - screen_x, @shape.body.p.y - screen_y, 0,
						15 * Math.sin(milliseconds / 300.0))
	end
end

# Player class.
class Player
	attr_reader :shape

	def initialize(window, shape)
		@shape = shape
		@shape.body.p = CP::Vec2.new(0.0, 0.0) # position
		@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity

		@dir = :left
		@vy = 0 # Vertical velocity
		@map = window.map

		# Load all animation frames
		@standing, @walk1, @walk2, @jump =
			*Image.load_tiles(window, "media/CptnRuby.png", TILE_SIZE, TILE_SIZE, false)
		# This always points to the frame that is currently drawn.
		# This is set in update, and used in draw.
		@cur_image = @standing    

		# Keep in mind that down the screen is positive y, which means that PI/2 radians,
		# which you might consider the top in the traditional Trig unit circle sense is actually
		# the bottom; thus 3PI/2 is the top
		@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen
	end

	def draw(screen_x, screen_y)
		# Flip vertically when facing to the left.
		#if @dir == :left then
			#offs_x = -25
			#factor = 1.0
		#else
			#offs_x = 25
			#factor = -1.0
		#end
		#@cur_image.draw(@x - screen_x + offs_x, @y - screen_y - 49, 0, factor, 1.0)

		@cur_image.draw_rot(@shape.body.p.x, @shape.body.p.y, ZOrder::Player, @shape.body.a * 180.0 / Math::PI + 90)
	end

	# Could the object be placed at x + offs_x/y + offs_y without being stuck?
	#def would_fit(offs_x, offs_y)
		# Check at the center/top and center/bottom for map collisions
	#	not @map.solid?(@x + offs_x, @y + offs_y) and
	#	not @map.solid?(@x + offs_x, @y + offs_y - 45)
	#end

	def update(move_x, move_y)
		# Select image depending on action
		if (move_x == 0)
			@cur_image = @standing
		else
			@cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
		end
		if (@vy < 0)
			@cur_image = @jump
		end
	end

	# Directly set the position of our Player
	def warp(vect)
		@shape.body.p = vect
	end

	# Apply negative Torque; Chipmunk will do the rest
	# SUBSTEPS is used as a divisor to keep turning rate constant
	# even if the number of steps per update are adjusted
	def move_left
		#@shape.body.t -= 300.0/SUBSTEPS
		@shape.body.apply_force((CP::Vec2.new(-5, 0) * (300.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
	end

	# Apply positive Torque; Chipmunk will do the rest
	# SUBSTEPS is used as a divisor to keep turning rate constant
	# even if the number of steps per update are adjusted
	def move_right
		#@shape.body.t += 300.0/SUBSTEPS
		@shape.body.apply_force((CP::Vec2.new(5, 0) * (300.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
	end

	# Apply forward force; Chipmunk will do the rest
	# SUBSTEPS is used as a divisor to keep acceleration rate constant
	# even if the number of steps per update are adjusted
	# Here we must convert the angle (facing) of the body into
	# forward momentum by creating a vector in the direction of the facing
	# and with a magnitude representing the force we want to apply
	def jump
		@shape.body.apply_force((@shape.body.a.radians_to_vec2 * (3000.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
	end

	def try_to_jump
		if @map.solid?(@x, @y + 1) then
			@vy = -20
		end
	end
end

# Map class holds and draws tiles and gems.
class Map
	attr_reader :width, :height, :gems
	attr_accessor :window

	def initialize(window, filename)
		@window = window
		@space = window.space

		# Load 60x60 tiles, 5px overlap in all four directions.
		@tileset = Image.load_tiles(window, "media/CptnRuby Tileset.png", 60, 60, true)
		@sky = Image.new(window, "media/kanzapanoid_sky.png", true)
		@skyx = 0.0

		gem_img = Image.new(window, "media/CptnRuby Gem.png", false)
		@gems = []

		lines = File.readlines(filename).map { |line| line.chop }
		@height = lines.size
		@width = lines[0].size

		@tiles = Array.new(@width) do |x|
			Array.new(@height) do |y|
				case lines[y][x, 1]
					when '"'
						Tiles::Grass
					when '#'
						Tiles::Earth
					when 'x'
						body = CP::Body.new(0.0001, 0.0001)
						shape = CP::Shape::Circle.new(body, 10, CP::Vec2.new(0.0, 0.0))
						shape.collision_type = :gem

						@space.add_body(body)
						@space.add_shape(shape)

						vect = CP::Vec2.new(x * TILE_SIZE + 25, y * TILE_SIZE + 25)

						@gems.push(CollectibleGem.new(gem_img, shape, vect))
						nil
					else
						nil
				end
			end
		end
	end

	def draw(screen_x, screen_y)
		# Sigh, stars!
		@sky.draw(screen_x * -1, screen_y * -1, ZOrder::Background)

		# Very primitive drawing function:
		# Draws all the tiles, some off-screen, some on-screen.
		@height.times do |y|
			@width.times do |x|
				tile = @tiles[x][y]
				if tile
					realx = x * TILE_SIZE
					realy = y * TILE_SIZE
					if realx > (screen_x - 100) and realx < (screen_x + SCREEN_WIDTH) and realy > (screen_y - 100) and realy < (screen_y + SCREEN_HEIGHT)
						# Draw the tile with an offset (tile images have some overlap)
						# Scrolling is implemented here just as in the game objects.
						@tileset[tile].draw(realx - screen_x - 5, realy - screen_y - 5, 0)
					end
				end
			end
		end
		@gems.each { |c| c.draw(screen_x, screen_y) }
	end

	# Solid at a given pixel position?
	def solid?(x, y)
		y < 0 || @tiles[x / TILE_SIZE][y / TILE_SIZE]
	end
end

class Game < Window
	attr_reader :map, :space

	def initialize
		super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
		self.caption = "Cptn. Ruby"

		# Put the beep here, as it is the environment now that determines collision
		@beep = Gosu::Sample.new(self, "media/Beep.wav")

		# Put the score here, as it is the environment that tracks this now
		@score = 0
		@font = Gosu::Font.new(self, Gosu::default_font_name, 20)

		# Time increment over which to apply a physics "step" ("delta t")
		@dt = (1.0/60.0)

		# Create our Space and set its damping and gravity
		@space = CP::Space.new
		@space.damping = 0.8
		@space.gravity = CP::Vec2.new(0.0, 5.0)

		# Create the Body for the Player
		body = CP::Body.new(10.0, 150.0)

		# In order to create a shape, we must first define it
		# Chipmunk defines 3 types of Shapes: Segments, Circles and Polys
		# We'll use s simple, 4 sided Poly for our Player (ship)
		# You need to define the vectors so that the "top" of the Shape is towards 0 radians (the right)
		shape_array = [CP::Vec2.new(-25.0, -25.0), CP::Vec2.new(-25.0, 25.0), CP::Vec2.new(25.0, 1.0), CP::Vec2.new(25.0, -1.0)]
		shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

		# The collision_type of a shape allows us to set up special collision behavior
		# based on these types.  The actual value for the collision_type is arbitrary
		# and, as long as it is consistent, will work for us; of course, it helps to have it make sense
		shape.collision_type = :ship

		@space.add_body(body)
		@space.add_shape(shape)

		@player = Player.new(self, shape)
		@player.warp(CP::Vec2.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)) # move to the center of the window

		# Scrolling is stored as the position of the top left corner of the screen.
		@screen_x = @screen_y = 0
		@camera_x,  @camera_y = SCREEN_WIDTH / 4, SCREEN_HEIGHT / 2

		@map = Map.new(self, "media/CptnRuby Map.txt")
	end

	def update
		# Step the physics environment SUBSTEPS times each update
		SUBSTEPS.times do

			# Scrolling follows player
			@screen_x = [[@player.shape.body.p.x - (SCREEN_WIDTH / 2), 0].max, @map.width * TILE_SIZE - SCREEN_WIDTH].min
			@screen_y = [[@player.shape.body.p.y - (SCREEN_HEIGHT / 2), 0].max, @map.height * TILE_SIZE - SCREEN_HEIGHT].min

			#@camera_x = @player.shape.body.p.x
			#@camera_y = @player.shape.body.p.y

			# When a force or torque is set on a Body, it is cumulative
			# This means that the force you applied last SUBSTEP will compound with the
			# force applied this SUBSTEP; which is probably not the behavior you want
			# We reset the forces on the Player each SUBSTEP for this reason
			@player.shape.body.reset_forces

			# Check keyboard
			if button_down? Gosu::Button::KbLeft
				@player.move_left
			end
			if button_down? Gosu::Button::KbRight
				@player.move_right
			end

			if button_down? Gosu::Button::KbUp
				@player.jump
			end

			# Perform the step over @dt period of time
			# For best performance @dt should remain consistent for the game
			@space.step(@dt)
		end
	end

	def draw
		@map.draw @screen_x, @screen_y
		@player.draw @screen_x, @screen_y
	end

	def button_down(id)
		#if id == Button::KbUp then @player.try_to_jump end
		if id == Button::KbEscape then close end
	end
end

Game.new.show
