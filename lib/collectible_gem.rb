class CollectibleGem < Item
	def initialize(window, location)
		image = Image.new(window, "media/CptnRuby Gem.png", false)

		body = CP::Body.new(0.0001, 0.0001)
		shape = CP::Shape::Circle.new(body, 10, CP::Vec2.new(0.0, 0.0))

		super(window, image, shape, location)
	end
end

