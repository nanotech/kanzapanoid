require 'weapon'

class AssaultRifle < Weapon
	def initialize(screen, location)
		shape_array = [
			CP::Vec2.new(-22, -18), # bottom left
			CP::Vec2.new(-22, 22), # bottom right
			CP::Vec2.new(160, 23), # top right
			CP::Vec2.new(160, -23) # top left
		]

		inertia = CP.moment_for_poly(10.0, shape_array, CP::Vec2.new(0,0))

		body = CP::Body.new(10.0, inertia)
		shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

		super(screen, location, shape)
	end
end

