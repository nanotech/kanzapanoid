class BodyPart
	attr_accessor :image, :x, :y, :z, :origin_x, :origin_y, :offset_x, :offset_y, :angle, :parent
	attr_reader :radius

	def initialize(character, xyz, origin, image, parent=nil)
		@character = character
		@window = character.window
		@image = image

		@x = xyz[0]
		@y = xyz[1]
		@z = xyz[2]

		@origin_x = origin[0]
		@origin_y = origin[1]

		@parent = parent

		@offset_x = 0
		@offset_y = 0
		@angle = 0.0

		@radius = Math.hypot(@x, @y)
	end

	def draw(angle=@angle)
		if @parent and @parent.is_a?(Symbol)
			@parent = @character.body_parts[@parent]
		end

		@angle = angle

		theta = Math.atan2(@x, @y) + @character.shape.body.a
		theta += @parent.angle.degrees_to_radians - 90 if @parent

		@offset_x = @radius * Math::cos(theta)
		@offset_y = @radius * Math::sin(theta)

		if @parent and @parent.offset_x
			@offset_x += @parent.offset_x
			@offset_y += @parent.offset_y
			@angle += @parent.angle
		end

		@image.draw_rot(
			@character.shape.body.p.x - @window.camera_x + @offset_x,
			@character.shape.body.p.y - @window.camera_y + @offset_y,
			@z,
			@character.shape.body.a.radians_to_gosu + @angle,
			@origin_x, @origin_y
		)
	end
end

