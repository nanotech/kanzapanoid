require 'item'

class Items
	attr_accessor :items

	def initialize(window)
		@items = []
	end

	def draw
		@items.each do |item|
			item.draw
		end
	end

	def add(item)
		@items.push item
	end
end

