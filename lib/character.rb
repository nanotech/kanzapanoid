require 'body_part'
require 'animation'

class Character
	attr_reader :shape, :body_parts, :window

	include AnimatorAPI

	def initialize(window, position=window.center)
		@window = window

		# In order to create a shape, we must first define it
		# Chipmunk defines 3 types of Shapes: Segments, Circles and Polys
		# We'll use s simple, 4 sided Poly for our Player
		# You need to define the vectors so that the "top" of the Shape is towards 0 radians (the right)
		shape_array = [
			CP::Vec2.new(-14, -18), # bottom left
			CP::Vec2.new(-14, 22), # bottom right
			CP::Vec2.new(170, 23), # top right
			CP::Vec2.new(170, -23) # top left
		]

		inertia = CP.moment_for_poly(10.0, shape_array, CP::Vec2.new(0,0))

		# Create the Body for the Player
		body = CP::Body.new(10.0, inertia)
		@shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

		# Set up physical properties
		@shape.body.p = position
		@shape.u = 1.0 # friction

		# Keep in mind that down the screen is positive y, which means that PI/2 radians,
		# which you might consider the top in the traditional Trig unit circle sense is actually
		# the bottom; thus 3PI/2 is the top
		@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen

		# Add the Player to Space
		body.add_to_space(@window.space)
		@shape.add_to_space(@window.space)

		@body_parts = {}
		@walking = :left
		@animation = Animator.new
	end

	def draw
		@body_parts.each do |part_name, part|
			part.draw @animation.render(part_name)
		end
	end

	def update
		@animation.update #if @update_animation == true
	end

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

	def walk_left; self.walk :left end
	def walk_right; self.walk :right end

	def walk(direction)
		@walking = direction
		@update_animation = true

		# Multiplying by -1 inverts a number,
		# thus we can use it to change direction.
		case direction
			when :left then direction = -1
			when :right then direction = 1
		end

		@shape.body.apply_impulse(CP::Vec2.new(5 * direction, 0) * (10.0), CP::Vec2.new(0.0, 0.0))

		if @shape.surface_v.x * direction < 5000.0
			if (@shape.surface_v.x * direction) >= 0 # changing directions?
				@shape.surface_v.x -= 200.0 * direction
			else
				@shape.surface_v.x -= 100.0 * direction
			end
		end
	end

	def spin_left
		@shape.body.apply_impulse(CP::Vec2.new(1, 0) * (20.0), CP::Vec2.new(250.0, 250.0))
	end
	def spin_right
		@shape.body.apply_impulse(CP::Vec2.new(1, 0) * (20.0), CP::Vec2.new(-250.0, -250.0))
	end

	def jump
		@shape.body.apply_impulse(CP::Vec2.new(0, -15) * (20.0), CP::Vec2.new(0.0, 0.0))
	end

	def duck
		@shape.body.apply_impulse(CP::Vec2.new(0, 15) * (20.0), CP::Vec2.new(0.0, 0.0))
	end

	def stop
		@walking = false
		@update_animation = false
		@shape.surface_v = CP::Vec2.new(0,0)
	end
end

