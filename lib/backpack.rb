class Backpack
	attr_reader :contents

	def initialize(screen)
		@screen = screen
		@contents = []
	end

	def <<(item)
		@contents << item
	end

	def draw
		@contents.each_with_index do |item, i|
			top = item.context.screen.height - 70
			item.draw_icon i*60 + 20, top
		end
	end
end
