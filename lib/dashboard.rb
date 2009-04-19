# Draws a number of Components onto the Screen in a HUD-like fashion.
class Dashboard
	attr_reader :components, :screen

	def initialize(screen)
		@screen = screen
		@components = []
	end

	# Plugs in a Component.
	def plugin(component)
		@components << component
	end

	# Draws the Dashboard.
	def draw
		h = 120 # height
		t = @screen.window.height - h # top
		w = @screen.window.width

		@screen.window.draw_line(
			0, t, 0x55ffffff,
			w, t, 0x55ffffff,
			ZOrder::Dashboard
		)

		@screen.window.draw_quad(
			0, t, 0x99000000,
			w, t, 0x99000000,
			0, t + h, 0xff000000,
			w, t + h, 0xff000000,
			ZOrder::Dashboard
		)

		@components.each_with_index do |c,i|
			c.draw 30, @screen.window.height - 80, ZOrder::Dashboard + i
		end
	end
end
