require 'body_part'
require 'animation'

class Character
	attr_reader :body, :body_parts, :window
	attr_accessor :angle_correction, :animator

	include AnimatorAPI

	def initialize(screen, body, position=window.center)
		@screen = screen
		@window = screen.window

		# Add the body to the space
		@body = body
		@body.add_to_space @screen.space

		@body_parts = {}
		@facing = :left
		@animator = Animator.new

		@angle_correction = false
		@back_from = 0
	end

	def draw
		@body_parts.each do |part_name, part|
			part.draw @animator.render(part_name), @facing == :left
		end
	end

	def update
		keep_up
		@animator.update #if @update_animation == true
	end

	def keep_up
		if @angle_correction
			radian_angle = @body.a + (Math::PI / 2)

			if Math::sin(@body.a) > -0.985
				if @back_from != radian_angle.sign
					return_vector = CP::Vec2.new(@back_from * -1, 0) * 200.0 * @body.w.abs
					@body.apply_impulse(return_vector, CP::Vec2.new(250.0, 250.0))
					@back_from = radian_angle.sign
				end
				@body.apply_impulse(CP::Vec2.new(radian_angle, 0) * (15.0), CP::Vec2.new(250.0, 250.0))
			end
		end
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

	def warp(vect); @body.p = vect end

	def walk_left; self.walk :left end
	def walk_right; self.walk :right end

	def walk(direction_sym)
		@update_animation = true

		# Multiplying by -1 inverts a number,
		# thus we can use it to change direction.
		direction = facing_sign(direction_sym)

		@body.apply_impulse(CP::Vec2.new(30 * direction, 0), CP::Vec2.new(0.0, 0.0))

		if @torso.surface_v.x * direction < 5000.0
			if @facing != direction_sym # changing directions?
				@torso.surface_v.x = 0.0
				@body.apply_impulse(@body.v * -1, CP::Vec2.new(0.0, 0.0))
			end

			@torso.surface_v.x -= 100.0 * direction
		end

		@facing = direction_sym #if @torso.body.vel.x * direction > 0
	end

	def spin_left
		@body.apply_impulse(CP::Vec2.new(1, 0) * (20.0), CP::Vec2.new(250.0, 250.0))
	end
	def spin_right
		@body.apply_impulse(CP::Vec2.new(1, 0) * (20.0), CP::Vec2.new(-250.0, -250.0))
	end

	def jump
		@body.apply_impulse(CP::Vec2.new(0, -15) * (20.0), CP::Vec2.new(0.0, 0.0))
	end

	def duck
		@body.apply_impulse(CP::Vec2.new(0, 15) * (20.0), CP::Vec2.new(0.0, 0.0))
	end

	def stop
		@update_animation = false
		@torso.surface_v = CP::Vec2.new(0,0)
	end

	def facing_sign(facing=@facing)
		facing == :right ? 1 : -1
	end
end

