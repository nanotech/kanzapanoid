require 'item'

class Items
	attr_accessor :items, :available_items

	def initialize(map)
		# Look for items
		@available_items = scan

		@window = map.window
		@items = []

		register_yaml_types
	end

	def draw
		@items.each do |item|
			item.draw
		end
	end

	def scan(directory='items')
		items = []
		Dir.foreach directory do |f|
			if f !~ /^\./ # Don't add if the filename starts with a dot
				items << f
			end
		end

		items
	end

	def get(item)
		require "items/#{item.underscore}/controller.rb"
	end

	def create(item, *args)
		item = item.to_s
		get item
		item.constantize.new(@window, *args)
	end

	def add(item, *args)
		@items.push create(item, *args)
	end

	def register_yaml_types
		@available_items.each do |item|
			item = item.camelize
			get item

			YAML::add_domain_type('kanzapanoid.nanotechcorp.net,2008-12-08', 'item-'+item) do |type, values|
				self.create item, item.constantize.from_yaml_with(values)
			end
		end
	end
end

