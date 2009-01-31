require 'body_part'
require 'animation'

class Character
	attr_reader :body, :body_parts, :window
	attr_accessor :angle_correction

	include AnimatorAPI

	def initialize(window, body, position=window.center)
		@window = window

		# Add the body to the space
		@body = body
		@body.add_to_space @window.space

		@body_parts = {}
		@walking = :left
		@animation = Animator.new

		@angle_correction = false
		@back_from = 0
	end

	def draw
		@body_parts.each do |part_name, part|
			part.draw @animation.render(part_name)
		end
	end

	def update
		keep_up
		@animation.update #if @update_animation == true
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

	def walk(direction)
		@walking = direction
		@update_animation = true

		# Multiplying by -1 inverts a number,
		# thus we can use it to change direction.
		case direction
			when :left then direction = -1
			when :right then direction = 1
		end

		@body.apply_impulse(CP::Vec2.new(5 * direction, 0) * (10.0), CP::Vec2.new(0.0, 0.0))

		if @torso.surface_v.x * direction < 5000.0
			if (@torso.surface_v.x * direction) >= 0 # changing directions?
				@torso.surface_v.x -= 200.0 * direction
			else
				@torso.surface_v.x -= 100.0 * direction
			end
		end
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
		@walking = false
		@update_animation = false
		@torso.surface_v = CP::Vec2.new(0,0)
	end
end

