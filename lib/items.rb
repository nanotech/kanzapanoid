require 'item'

#
# Items manages Items (Item, plurl).
#
# It provides auto-loading, pickups, and YAML serialization.
#
class Items
	attr_reader :screen
	attr_accessor :items, :available_items

	def initialize(map)
		# Look for items
		@available_items = scan

		@screen = map.screen
		@items = []
		@remove_items = []

		register_collisions
		register_yaml_types
	end

	def draw
		@items.each do |item|
			item.draw
		end
	end

	def update
		@remove_items.each do |item|
			item.destroy
			@items.delete item
		end
		@remove_items.clear
	end

	def scan(directory='items')
		items = {}
		Dir.foreach directory do |item_name|
			if item_name !~ /^\./ # Don't add if the filename starts with a dot
				get item_name
				items[item_name.to_sym] = item_name.constantize
			end
		end

		items
	end

	def get(item)
		item = item.underscore
		require "items/#{item}/#{item}.rb"
	end

	def create(item, *args)
		item = item.to_s
		get item
		item.constantize.new self, *args
	end

	def add(item_type, *args)
		@items.push create(item_type, *args)
	end

	def remove(item)
		@remove_items << item
	end

	def insert(item)
		@items << item
	end

	def register_collisions
		@available_items.each do |item_name, item_class|
			[:player].each do |other|
				@screen.space.add_collision_func(item_name, other) do |a_shape, b_shape|
					if a_shape.obj.collided_with b_shape.obj
						@remove_items << a_shape.obj
					end
				end
			end
		end
	end

	def register_yaml_types
		@available_items.each do |item_name, item_class|
			YAML::add_domain_type('kanzapanoid.nanotechcorp.net,2008-12-08', "item-#{item_name.to_s.camelize}") do |type, values|
				self.create item_name, item_class.from_yaml_with(values)
			end
		end
	end
end

