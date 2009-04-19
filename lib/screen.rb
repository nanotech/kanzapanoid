#
# *DEPRECATED!* Don't use this file, use either Screens, or just a Window instead.
#

begin
	require 'rubygems'
rescue LoadError
end

require 'gosu'
include Gosu

require 'helpers'

class Screen < Window
	attr_reader :width, :height, :center, :fullscreen
	attr_accessor :camera

	def initialize(caption='', width=1280, ratio=Rational(16,10), fullscreen=false)
		@width = width
		@height = (width / ratio).numerator
		@center = [@width / 2, @height / 2]
		@fullscreen = fullscreen

		super(@width, @height, @fullscreen)

		self.caption = caption
		$last_time = milliseconds

		# Scrolling is stored as the position of the top left corner of the screen.
		@camera = [0, 0]
	end

	# For backwards compatibility
	def camera_x; @camera.x end
	def camera_y; @camera.y end

	def update
		$last_time = milliseconds
	end

	# Placeholder function
	def draw; end

	# Default key mappings
	def button_down(id)
		if id == Button::KbEscape then close end
	end
end
