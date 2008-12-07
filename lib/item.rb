class Item
	def initialize(window, image, shape, location, space=window.space)
		@window = window
		@image = image
		@space = space

		@shape = shape
		@shape.body.p = location
		@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
		@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen

		@shape.body.add_to_space(@space)
		@shape.add_to_space(@space)
	end

	def draw
		# Draw, slowly rotating
		@image.draw_rot(@shape.body.p.x - @window.camera_x, @shape.body.p.y - @window.camera_y, 0,
						15 * Math.sin(milliseconds / 300.0))
	end

	def destroy
		@shape.body.remove_from_space(@space)
		@shape.remove_from_space(@space)
	end
end

