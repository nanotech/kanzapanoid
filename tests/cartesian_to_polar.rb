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

SUBSTEPS = 1

$LOAD_PATH.push '../lib/'

require 'helpers'

# Layering of sprites
module ZOrder
	Background, Tiles, Items, Player, UI = *0..5
end

class Game < Window
	attr_reader :map, :space, :camera_x, :camera_y

	def initialize
		super(Screen::Width, Screen::Height, false)
		self.caption = "Trigonomitry Test"

		@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
	end

	def update
		@x = mouse_x - Screen::Center[0]
		@y = mouse_y - Screen::Center[1]

		@distance = Math.hypot(@x, @y)
		@theta = Math.atan2(@x, @y) - Math::PI / 2

		@wx = @distance * Math::cos(@theta)
		@wy = @distance * -Math::sin(@theta)
	end

	def draw
		self.draw_line(@wx + Screen::Center[0], @wy + Screen::Center[1], 0xff009999,
					   Screen::Center[0], Screen::Center[1], 0xffffffff,
					   10)

		self.draw_line(@x + Screen::Center[0], @y + Screen::Center[1], 0x22990000,
					   Screen::Center[0], Screen::Center[1], 0xffffffff,
					   10)

		#@font.draw("θ#{@theta} r#{@distance.round}", @x + Screen::Center[0], @y + Screen::Center[1], ZOrder::UI)
	end

	def button_down(id)
		if id == Button::KbEscape then close end
	end
end

Game.new.show

