class CollectibleGem
	attr_reader :shape

	def initialize(image, shape, vect)
		@image = image

		@shape = shape
		@shape.body.p = vect
		@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
		@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen
	end

	def draw(screen_x, screen_y)
		# Draw, slowly rotating
		@image.draw_rot(@shape.body.p.x - screen_x, @shape.body.p.y - screen_y, 0,
						15 * Math.sin(milliseconds / 300.0))
	end
end

