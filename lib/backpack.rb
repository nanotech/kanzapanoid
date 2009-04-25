# A Backpack contains Items (Item, plurl, not the class, Items).
# It's items are then usually displayed by a Dashboard.
class Backpack
	attr_reader :contents

	def initialize(dashboard)
		@dashboard = dashboard
		@contents = {}
	end

	# Draws the items in the Backpack using the Item's #draw_icon method.
	def draw(x, y, z)
		@contents.values.flatten.each_with_index do |item, i|
			item.draw_icon i*60 + x, y, z, :animate
		end
	end

	# Adds an Item to the Backpack.
	def push(item)
		@contents[item.class] = [] unless @contents[item.class]
		@contents[item.class].push item
	end

	alias << push

	# Removes an Item from the Backpack of the given type.
	def get(type)
		@contents[type].pop
	end

	# *DEPRICATED*: Use #get instead.
	# Removes an Item from the Backpack.
	def pop
		key = @contents.reject { |k,v| v.empty? }.keys[0]
		ary = @contents[key]
		ary.pop if ary
	end
end
