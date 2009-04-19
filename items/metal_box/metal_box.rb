class MetalBox < Item
	def initialize(window, location)
		shape_array = [
			CP::Vec2.new(-29, -29), # bottom left
			CP::Vec2.new(-29, 29), # bottom right
			CP::Vec2.new(29, 29), # top right
			CP::Vec2.new(29, -29) # top left
		]

		mass = 29
		inertia = CP.moment_for_poly(mass, shape_array, CP::Vec2.new(0,0))

		body = CP::Body.new(mass, inertia)
		shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

		super(window, location, shape)
	end
end
