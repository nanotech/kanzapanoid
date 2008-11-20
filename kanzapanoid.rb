#!/usr/bin/ruby
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

require 'player'
require 'items'
require 'tilemap'
require 'helpers'

# Layering of sprites
module ZOrder
	Background, Tiles, Items, Player, UI = *0..5
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
		shape_size = 20.0
		shape_array = [
			CP::Vec2.new(-shape_size, -shape_size),
			CP::Vec2.new(-shape_size, shape_size),
			CP::Vec2.new(shape_size, shape_size),
			CP::Vec2.new(shape_size, -shape_size)
		]
		shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

		# The collision_type of a shape allows us to set up special collision behavior
		# based on these types.  The actual value for the collision_type is arbitrary
		# and, as long as it is consistent, will work for us; of course, it helps to have it make sense
		shape.collision_type = :player

		@space.add_body(body)
		@space.add_shape(shape)

		@player = Player.new(self, shape, CP::Vec2.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2))
		#@player.warp(CP::Vec2.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)) # move to the center of the window

		# Scrolling is stored as the position of the top left corner of the screen.
		@screen_x = @screen_y = 0
		@camera_x = @camera_y = 0

		@map = Map.new(self, "media/CptnRuby Map.txt")
	end

	def update
		# Step the physics environment SUBSTEPS times each update
		SUBSTEPS.times do

			# Scrolling follows player
			#@screen_x = [[@player.shape.body.p.x - (SCREEN_WIDTH / 2), 0].max, @map.width * TILE_SIZE - SCREEN_WIDTH].min
			#@screen_y = [[@player.shape.body.p.y - (SCREEN_HEIGHT / 2), 0].max, @map.height * TILE_SIZE - SCREEN_HEIGHT].min

			@camera_x = @player.shape.body.p.x - (SCREEN_WIDTH / 2)
			@camera_y = @player.shape.body.p.y - (SCREEN_HEIGHT / 2)

			#if @camera_x < 0 then @camera_x = 0 end

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

			if button_down? Gosu::Button::KbDown
				@player.duck
			end

			# Perform the step over @dt period of time
			# For best performance @dt should remain consistent for the game
			@space.step(@dt)
		end
	end

	def draw
		@map.draw @camera_x, @camera_y
		@player.draw @camera_x, @camera_y
	end

	def button_down(id)
		#if id == Button::KbUp then @player.try_to_jump end
		if id == Button::KbEscape then close end
		if id == Button::KbSpace then puts @player.shape.body.v end
	end
end

Game.new.show

