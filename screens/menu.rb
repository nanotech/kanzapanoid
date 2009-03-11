class Menu < Screen
	def initialize(*args)
		super
		@font = Font.new @window, Gosu::default_font_name, 40

		@text = [
			"This is where the fancy menu will go.",
			"Until then, press the space bar to start.",
			"If you decide you want to exit, press Q."
		]
	end

	def draw
		@text.each_with_index do |line, i|
			@font.draw(line, 20, (i * 42) + 20, 0)
		end
	end

	def button_down(id)
		case id
		when KbQ; close
		when KbSpace, KbEscape; switch_to :game
		end
	end
end
