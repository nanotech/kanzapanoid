#!/usr/bin/env ruby

#
# Kanzapanoid Game entry point
#

$LOAD_PATH.push 'lib/'

require 'screen'
require 'audio'

require 'chipmunk'
include CP

require 'vectormap'
require 'player'

# Layering of sprites
module ZOrder
	Background, Tiles, Items, Player, UI = *0..5
end

class Game < Screen
	attr_reader :map, :space

	def initialize
		super('Kanzapanoid', 1280, Rational(16,10))

		# Put the score here, as it is the environment that tracks this now
		@score = 0
		@font = Font.new(self, Gosu::default_font_name, 20)

		# Time increment over which to apply a physics "step" ("delta t")
		@dt = (1.0/60.0)

		# Create our Space and set its damping and gravity
		@space = Space.new
		@space.damping = 0.8
		@space.gravity = Vec2.new(0.0, 600.0)

		@player = Player.new self, Vec2.new(300.0, 200.0)

		@map = VectorMap.new self
		@map.open 'test'

		@audio = Audio.new self, 'steps'
		@beep = @audio.load 'beep'
	end

	def update
		# Scrolling follows player
		@camera.x = @player.shape.body.p.x - (@width / 2)
		@camera.y = @player.shape.body.p.y - (@height / 2)

		# Check keyboard
		if button_down? KbLeft then @player.walk_left end
		if button_down? KbRight then @player.walk_right end
		if !button_down? KbLeft and !button_down? KbRight
			@player.stop
		end

		if button_down? self.char_to_button_id('a') then @player.spin_left end
		if button_down? self.char_to_button_id('d') then @player.spin_right end

		if button_down? KbUp then @player.jump end
		if button_down? KbDown then @player.duck end

		# Perform the step over @dt period of time
		# For best performance @dt should remain consistent for the game
		@space.step(@dt)

		@audio.update
		@player.update

		$last_time = milliseconds
	end

	def draw
		@map.draw
		@player.draw
	end

	def button_down(id)
		super

		if id == KbSpace then @audio.play @beep; @audio.samples[0].reset end
		if id == KbLeftShift then @audio.samples[0].left end
		if id == KbRightShift then @audio.samples[0].right end
		if id == Kb1 then @audio.samples[0].fade_out end
		if id == Kb2 then @audio.samples[0].fade_in end
		if id == Kb3 then @audio.samples[0].speed_to(0) end
		if id == Kb4 then @audio.samples[0].speed_to(2) end
	end
end

Game.new.show

