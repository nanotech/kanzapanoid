class Character
	attr_reader :shape

	def initialize(window, position=Screen::Center)
		@window = window

		# Create the Body for the Player
		body = CP::Body.new(10.0, 1500.0)

		# In order to create a shape, we must first define it
		# Chipmunk defines 3 types of Shapes: Segments, Circles and Polys
		# We'll use s simple, 4 sided Poly for our Player
		# You need to define the vectors so that the "top" of the Shape is towards 0 radians (the right)
		shape_width = 120.0
		shape_height = 65.0
		shape_array = [
			CP::Vec2.new(-shape_width, -shape_height), # top left
			CP::Vec2.new(-shape_width, shape_height), # bottom left
			CP::Vec2.new(shape_width, shape_height), # bottom right
			CP::Vec2.new(shape_width, -shape_height) # top right
		]
		@shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

		# Set up physical properties
		@shape.body.p = position
		@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
		@shape.u = 1.0 # friction

		# Add the Player to Space
		body.add_to_space(@window.space)
		@shape.add_to_space(@window.space)

		# Keep in mind that down the screen is positive y, which means that PI/2 radians,
		# which you might consider the top in the traditional Trig unit circle sense is actually
		# the bottom; thus 3PI/2 is the top
		@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen

		@body_parts = {}
	end

	def draw(screen_x, screen_y)
		@body_parts.each do |name, part|

			angle = animate(name)
			angle = @body_parts[name][:angle] unless angle

			theta = Math.atan2(part[:x], part[:y]) + @shape.body.a
			if part[:parent] and @body_parts[part[:parent]][:angle]
				theta += @body_parts[part[:parent]][:angle].degrees_to_radians - 90
			end

			offset_x = part[:radius] * Math::cos(theta)
			offset_y = part[:radius] * Math::sin(theta)

			if part[:parent] and @body_parts[part[:parent]][:offset_x]
				offset_x += @body_parts[part[:parent]][:offset_x]
				offset_y += @body_parts[part[:parent]][:offset_y]
				angle += @body_parts[part[:parent]][:angle]
			end

			@body_parts[name][:offset_x] = offset_x
			@body_parts[name][:offset_y] = offset_y
			@body_parts[name][:angle] = angle

			part[:image].draw_rot(
				@shape.body.p.x - @window.camera_x + offset_x,
				@shape.body.p.y - @window.camera_y + offset_y,
				part[:z],
				@shape.body.a.radians_to_gosu + angle,
				part[:origin][:x], part[:origin][:y]
			)
		end
	end

	def animate(part=false); 0; end

	def load_parts(parts)
		parts.each do |name, data|
			image = Image.new(@window, 'media/' + self.class.name.downcase + '/' + name.to_s + '.png', true)

			part = {
				:image => image,

				:x => data[0][0],
				:y => data[0][1],
				:z => data[2],

				:origin => {
					:x => data[1][0],
					:y => data[1][1]
				},

				:parent => data[3],

				:offset_x => 0.5,
				:offset_y => 0.5,
				:angle => 0.0,
			}

			part[:radius] = Math.hypot(part[:x], part[:y])

			@body_parts[name] = part
		end
	end

	def warp(vect); @shape.body.p = vect end

	def walk_left; self.walk 'left' end
	def walk_right; self.walk 'right' end

	def walk (direction)
		# Multiplying by -1 inverts a number,
		# thus we can use it to change direction.
		case direction
			when 'left' then direction = -1
			when 'right' then direction = 1
		end

		@shape.body.apply_impulse(CP::Vec2.new(5 * direction, 0) * (10.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))

		if @shape.surface_v.x * direction < 5000.0
			if (@shape.surface_v.x * direction) >= 0 # changing directions?
				@shape.surface_v.x -= 200.0 * direction
			else
				@shape.surface_v.x -= 100.0 * direction
			end
		end
	end

	def spin_left; @shape.body.t -= 10000.0/SUBSTEPS end
	def spin_right; @shape.body.t += 10000.0/SUBSTEPS end

	def jump
		#@shape.body.apply_force((@shape.body.a.radians_to_vec2 * (3000.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
		@shape.body.apply_impulse(CP::Vec2.new(0, -15) * (20.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end

	def duck
		#@shape.body.apply_force(-(@shape.body.a.radians_to_vec2 * (3000.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
		@shape.body.apply_force(CP::Vec2.new(0, 15) * (300.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end

	def stop; @shape.surface_v = CP::Vec2.new(0,0) end
end

