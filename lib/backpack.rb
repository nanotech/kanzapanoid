# A Backpack contains Items (Item, plurl, not the class, Items).
# It's items are then usually displayed by a Dashboard.
class Backpack
	attr_reader :contents

	def initialize(dashboard)
		@dashboard = dashboard
		@contents = []
	end

	# Draws the items in the Backpack using the Item's #draw_icon method.
	def draw(x, y, z)
		@contents.each_with_index do |item, i|
			item.draw_icon i*60 + x, y, z, :animate
		end
	end

	# Adds an Item to the Backpack.
	def <<(item)
		@contents << item
	end

	# Removes an Item from the Backpack.
	def pop
		@contents.pop
	end
end
