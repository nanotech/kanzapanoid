class BodyPart
	attr_accessor :image, :x, :y, :z, :origin_x, :origin_y,
				  :offset_x, :offset_y, :angle, :parent,
				  :animation

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

	def draw(angle, mirror=true)
		angle = 0 unless angle

		if @parent and @parent.is_a?(Symbol)
			@parent = @character.body_parts[@parent]
		end

		@angle = mirror ? -angle : angle

		theta = Math.atan2(mirror ? -@x : @x, @y) + @character.body.a
		theta += @parent.angle.degrees_to_radians + (mirror ? 90 : -90) if @parent

		@offset_x = @radius * Math::cos(theta)
		@offset_y = @radius * Math::sin(theta)

		if @parent and @parent.offset_x
			@offset_x += @parent.offset_x
			@offset_y += @parent.offset_y
			@angle += @parent.angle
		end

		@image.draw_rot(
			@character.body.p.x - @window.camera.x + @offset_x,
			@character.body.p.y - @window.camera.y + @offset_y,
			@z,
			@character.body.a.radians_to_gosu + @angle,
			@origin_x, @origin_y, mirror ? -1 : 1
		)
	end
end
