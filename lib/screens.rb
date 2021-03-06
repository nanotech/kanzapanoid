begin
	require 'rubygems'
rescue LoadError
end

require 'helpers'
require 'vector'
require 'gosu'
include Gosu

#
# Provides some common game features such
# as a camera, and screen/scene switching.
#
class Screens < Window
	attr_reader :width, :height, :center, :fullscreen
	attr_accessor :camera

	# Creates a new Window. Having more than one Window will crash Gosu.
	#
	# The Window's size is specified as a +width+, and a Rational ratio such
	# as <tt>Rational(4,3)</tt> or <tt>Rational(16,10)</tt>.
	def initialize(caption='', width=1280, ratio=Rational(16,10), fullscreen=false)
		@width = width
		@height = (width / ratio).numerator
		@center = [@width / 2, @height / 2]
		@fullscreen = (fullscreen != false)

		super(@width, @height, @fullscreen)

		self.caption = caption

		# Scrolling is stored as the position of the top left corner of the screen.
		@camera = Vector(0,0)

		@screens = {}
		@current_screen = nil
	end

	# Switches to the Screen specified, passing the given arguments, and
	# executing the optional block before leaving to the next Screen.
	def switch_to(screen, *args, &block) # :yield: old_screen, new_screen
		screen = screen.to_s

		required = require 'screens/' + screen.underscore

		if n = args.index(:cleanup)
			args.delete(n)
			run_after = Proc.new do
				destroy! @current_screen.name
			end
		end

		unless @screens[screen]
			klass = screen.constantize
			@screens[screen] = klass.new(self, screen, *args)
		end

		# Callbacks

		yield @current_screen, @screens[screen] if block
		run_after.call if run_after

		if @current_screen.respond_to?(:leave)
			@current_screen.send(:leave) 
		end

		if @screens[screen].respond_to?(:enter)
			@screens[screen].send(:enter) 
		end

		@current_screen = @screens[screen]
	end

	# Deletes a Screen.
	def destroy!(screen)
		@screens.delete(screen)
	end

	# Draws the current screen.
	# Don't forget to call +super+ if you override this!
	def draw; @current_screen.draw end

	# Updates the current screen.
	# Don't forget to call +super+ if you override this!
	def update; @current_screen.update end

	# Default key mappings
	def button_down(id)
		@current_screen.button_down(id)
	end
end

class Screen
	attr_accessor :window, :name

	def initialize(window, name)
		@window = window
		@name = name
		@height = window.height
		@width = window.width

		# Delegate methods we don't have to @window.
		(@window.methods - methods).each do |m|
			m = m.to_sym # convert the string to a symbol
			self.class.send(:define_method, m) do |*args|
				@window.send m, *args
			end
		end
	end

	# Override this!
	def draw; end
	# Override this!
	def update; end

	# Default keybindings:
	#     Esc => Close Window
	def button_down(id)
		if id == KbEscape then @window.close end
	end

	# Destroy this screen's state. The screen you're destroying probably
	# shouldn't be active when you do this.
	def destroy!
		@window.destroy! @name	
	end
end
