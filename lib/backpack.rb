class Backpack
	attr_reader :contents

	def initialize(dashboard)
		@dashboard = dashboard
		@contents = []
	end

	def <<(item)
		@contents << item
	end

	def draw(x, y, z)
		@contents.each_with_index do |item, i|
			item.draw_icon i*60 + x, y, z, :animate
		end
	end
end
