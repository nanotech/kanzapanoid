require 'item'

class Items
	attr_accessor :items, :available_items

	def initialize(map)
		# Look for items
		@available_items = scan

		@screen = map.screen
		@items = []

		register_yaml_types
	end

	def draw
		@items.each do |item|
			item.draw
		end
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
		require "items/#{item}/#{item}.rb"
	end

	def create(item, *args)
		item = item.to_s
		get item
		item.constantize.new(@screen, *args)
	end

	def add(item, *args)
		@items.push create(item, *args)
	end

	def register_yaml_types
		@available_items.each do |item_name, item_class|
			YAML::add_domain_type('kanzapanoid.nanotechcorp.net,2008-12-08', "item-#{item_name.to_s.camelize}") do |type, values|
				self.create item_name, item_class.from_yaml_with(values)
			end
		end
	end
end

