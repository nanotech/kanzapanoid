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

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480
TILE_SIZE = 50

module Tiles
	Grass = 0
	Earth = 1
end

class CollectibleGem
	attr_reader :x, :y

	def initialize(image, x, y)
		@image = image
		@x, @y = x, y
	end

	def draw(screen_x, screen_y)
		# Draw, slowly rotating
		@image.draw_rot(@x - screen_x, @y - screen_y, 0,
						15 * Math.sin(milliseconds / 300.0))
	end
end

# Player class.
class CptnRuby
	attr_reader :x, :y

	def initialize(window, x, y)
		@x, @y = x, y
		@dir = :left
		@vy = 0 # Vertical velocity
		@map = window.map
		# Load all animation frames
		@standing, @walk1, @walk2, @jump =
			*Image.load_tiles(window, "media/CptnRuby.png", TILE_SIZE, TILE_SIZE, false)
		# This always points to the frame that is currently drawn.
		# This is set in update, and used in draw.
		@cur_image = @standing    
	end

	def draw(screen_x, screen_y)
		# Flip vertically when facing to the left.
		if @dir == :left then
			offs_x = -25
			factor = 1.0
		else
			offs_x = 25
			factor = -1.0
		end
		@cur_image.draw(@x - screen_x + offs_x, @y - screen_y - 49, 0, factor, 1.0)
	end

	# Could the object be placed at x + offs_x/y + offs_y without being stuck?
	def would_fit(offs_x, offs_y)
		# Check at the center/top and center/bottom for map collisions
		not @map.solid?(@x + offs_x, @y + offs_y) and
		not @map.solid?(@x + offs_x, @y + offs_y - 45)
	end

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

		# Directional walking, horizontal movement
		if move_x > 0 then
			@dir = :right
			move_x.times { if would_fit(1, 0) then @x += 1 end }
		end
		if move_x < 0 then
			@dir = :left
			(-move_x).times { if would_fit(-1, 0) then @x -= 1 end }
		end
		if move_y < 0 then
			(-move_y).times { if would_fit(0, -1) then @y -= 1 end }
		end
		if move_y >= 0 then
			8.times do
				if would_fit(0, 1) then @y += 1 end
			end
		end

		# Acceleration/gravity
		# By adding 1 each frame, and (ideally) adding vy to y, the player's
		# jumping curve will be the parabole we want it to be.
		#@vy += 1
		# Vertical movement
		#if @vy > 0 then
			#@vy.times { if would_fit(0, 1) then @y += 0.2 else @vy = 0 end }
		#end
		#if @vy < 0 then
			#(-@vy).times { if would_fit(0, -1) then @y -= 1.5 else @vy = 0 end }
		#end
	end

	def try_to_jump
		if @map.solid?(@x, @y + 1) then
			@vy = -20
		end
	end

	def collect_gems(gems)
		# Same as in the tutorial game.
		gems.reject! do |c|
			(c.x - @x).abs < TILE_SIZE and (c.y - @y).abs < TILE_SIZE
		end
	end
end

# Map class holds and draws tiles and gems.
class Map
	attr_reader :width, :height, :gems
	attr_accessor :window

	def initialize(window, filename)
		@window = window

		# Load 60x60 tiles, 5px overlap in all four directions.
		@tileset = Image.load_tiles(window, "media/CptnRuby Tileset.png", 60, 60, true)
		@sky = Image.new(window, "media/Space.png", true)
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
						@gems.push(CollectibleGem.new(gem_img, x * TILE_SIZE + 25, y * TILE_SIZE + 25))
						nil
					else
						nil
				end
			end
		end
	end

	def draw(screen_x, screen_y)
		# Sigh, stars!
		@sky.draw(@skyx, 0, 0)

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
	attr_reader :map

	def initialize
		super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
		self.caption = "Cptn. Ruby"
		@map = Map.new(self, "media/CptnRuby Map.txt")
		@cptn = CptnRuby.new(self, 400, 100)
		# Scrolling is stored as the position of the top left corner of the screen.
		@screen_x = @screen_y = 0
	end
	def update
		move_x = move_y = 0
		move_x -= 5 if button_down? Button::KbLeft
		move_x += 5 if button_down? Button::KbRight
		move_y -= 10 if button_down? Button::KbUp
		@cptn.update(move_x, move_y)
		@cptn.collect_gems(@map.gems)
		# Scrolling follows player
		@screen_x = [[@cptn.x - 320, 0].max, @map.width * TILE_SIZE - 640].min
		@screen_y = [[@cptn.y - 240, 0].max, @map.height * TILE_SIZE - 480].min
	end
	def draw
		@map.draw @screen_x, @screen_y
		@cptn.draw @screen_x, @screen_y
	end
	def button_down(id)
		#if id == Button::KbUp then @cptn.try_to_jump end
		if id == Button::KbEscape then close end
	end
end

Game.new.show
