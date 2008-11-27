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

module Screen
	Width = 640
	Height = 480
	Center = CP::Vec2.new(self::Width / 2, self::Height / 2)
end

SUBSTEPS = 1

$LOAD_PATH.push 'lib/'

require 'vectormap'
require 'player'
require 'items'
require 'helpers'

# Layering of sprites
module ZOrder
	Background, Items, Player, UI = 0, 100, 200, 900
end

class Game < Window
	attr_reader :map, :space, :camera_x, :camera_y

	def initialize
		super(Screen::Width, Screen::Height, false)
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
		@space.gravity = CP::Vec2.new(0.0, 500.0)

		@player = Player.new self, CP::Vec2.new(300.0, 200.0)

		# Scrolling is stored as the position of the top left corner of the screen.
		@screen_x = @screen_y = 0
		@camera_x = @camera_y = 0

		#@map = VectorMap.new self
		#@map.open 'test'
	end

	def update
		# Step the physics environment SUBSTEPS times each update
		SUBSTEPS.times do

			# Scrolling follows player
			@camera_x = @player.shape.body.p.x - (Screen::Width / 2)
			@camera_y = @player.shape.body.p.y - (Screen::Height / 2)

			#if @camera_x < 0 then @camera_x = 0 end

			# When a force or torque is set on a Body, it is cumulative
			# This means that the force you applied last SUBSTEP will compound with the
			# force applied this SUBSTEP; which is probably not the behavior you want
			# We reset the forces on the Player each SUBSTEP for this reason
			@player.shape.body.reset_forces

			# Check keyboard
			if button_down? Gosu::KbLeft then @player.walk_left end
			if button_down? Gosu::KbRight then @player.walk_right end
			if !button_down? Gosu::KbLeft and !button_down? Gosu::KbRight
				@player.stop
			end

			if button_down? self.char_to_button_id('a') then @player.spin_left end
			if button_down? self.char_to_button_id('d') then @player.spin_right end

			if button_down? Gosu::KbUp then @player.jump end
			if button_down? Gosu::KbDown then @player.duck end

			# Perform the step over @dt period of time
			# For best performance @dt should remain consistent for the game
			@space.step(@dt)
		end

		@player.update
	end

	def draw
		#@map.draw
		@player.draw @camera_x, @camera_y
	end

	def button_down(id)
		if id == Button::KbEscape then close end
	end
end

Game.new.show

