class MetalBox < Item
	def initialize(window, location)
		body = CP::Body.new(0.1, 0.1)
		shape = CP::Shape::Circle.new(body, 29, CP::Vec2.new(0.0, 0.0))

		super(window, location, shape)
	end
end
