#!/usr/bin/ruby
Dir.chdir '..'
$LOAD_PATH.push 'lib/'
require 'screen'

require 'chipmunk'
include CP

require 'player'

class AnimationTest < Screen
	attr_reader :space

	def initialize
		super('Animation Test', 800, Rational(4,3), false)

		# Create our Space and set its damping and gravity
		@space = Space.new
		@space.damping = 0.8
		@space.gravity = Vec2.new(0.0, 0.0)

		# Time increment over which to apply a physics "step" ("delta t")
		@dt = (1.0/60.0)

		@player = Player.new self, Vec2.new(@width / 2, @height / 2)

		@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
	end

	def update
		@player.update

		@camera.x = @player.body.p.x - (@width / 2)
		@camera.y = @player.body.p.y - (@height / 2)

		# Check keyboard
		if button_down? KbLeft then @player.walk_left end
		if button_down? KbRight then @player.walk_right end
		if !button_down? KbLeft and !button_down? KbRight
			@player.stop
		end

		if button_down? KbA then @player.spin_left end
		if button_down? KbD then @player.spin_right end

		if button_down? KbUp then @player.jump end
		if button_down? KbDown then @player.duck end

		@space.step(@dt)
	end

	def draw
		@player.draw

		i = 0
		@player.animator.motions.map do |name, x|
			text = name.to_s + ": " + x.easer.value.round.to_s
			@font.draw(text, 20, 24 * i, 0)
			i += 1
		end
	end

	def button_down(id)
		if id == KbEscape then close end
		if id == KbS then @player.animator.group = :standing end
		if id == KbW then @player.animator.group = :walking end
	end
end

AnimationTest.new.show
