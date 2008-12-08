require 'body_part'

class Character
	attr_reader :shape, :body_parts, :window

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

	def draw
		@body_parts.each do |part_name, part|
			part.draw animate(part_name)
		end
	end

	def animate(part=false); 0; end

	def load_parts(parts)
		parts.each do |name, data|
			image = Image.new(@window,
							  'media/' + self.class.name.downcase \
							  + '/' + name.to_s + '.png', false)
			xyz = data[0]
			xyz[2] = data[2]
			origin = data[1]
			parent = data[3]

			@body_parts[name] = BodyPart.new(self, xyz, origin, image, parent)
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

