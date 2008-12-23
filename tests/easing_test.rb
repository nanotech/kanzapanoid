#!/usr/bin/ruby
begin
	# In case you use Gosu via rubygems.
	require 'rubygems'
rescue LoadError
	# In case you don't.
end

require 'gosu'
include Gosu

module Screen
	Width = 640
	Height = 480
	Center = [self::Width / 2.0, self::Height / 2.0]
end

$LOAD_PATH.push '../lib/'

require 'helpers'
require 'fader'

class EasingTest < Window
	def initialize
		super(Screen::Width, Screen::Height, false)
		self.caption = 'Easer Test'

		@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
		@easer = Easer.new 0.0
		@easer.to 300.0, 2000
	end

	def update
		@easer.update

		# Flip directions when it finishes an ease
		if @easer.time >= @easer.duration
			if @easer.value > 0
				@easer.to -300.0, 2000
			else
				@easer.to 300.0, 2000
			end
		end
	end

	def draw
		self.draw_line(@easer.value + Screen::Center[0], 
					   Screen::Center[1], 0xffffffff,
					   Screen::Center[0], Screen::Center[1], 0xffffffff, 0)

		@font.draw(@easer.to_s, Screen::Center[0], Screen::Center[1], 0)
	end

	def button_down(id)
		if id == Button::KbEscape then close end
	end
end

EasingTest.new.show
