require 'character'
require 'backpack'

class Player < Character
	def initialize(screen, position=window.center)
		shape_array = [
			CP::Vec2.new(-22, -18), # bottom left
			CP::Vec2.new(-22, 22), # bottom right
			CP::Vec2.new(160, 23), # top right
			CP::Vec2.new(160, -23) # top left
		]

		inertia = CP.moment_for_poly(10.0, shape_array, CP::Vec2.new(0,0))

		# Create the Body for the Player
		body = CP::Body.new(10.0, inertia)
		@torso = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

		# Set up physical properties
		@torso.body.p = position
		@torso.u = 1.0 # friction

		@torso.body.a = -(Math::PI/2) # angle in radians; faces towards top of screen

		super(screen, body, position)

		@torso.add_to_space(@screen.space)

		# The collision_type of a shape allows us to set up special collision behavior
		# based on these types. The actual value for the collision_type is arbitrary
		# and, as long as it is consistent, will work for us; of course, it helps to have it make sense
		@torso.collision_type = :player
		@torso.obj = self

		@backpack = Backpack.new @screen
		@screen.dashboard.plugin @backpack

		# Enable angle correction
		@angle_correction = true

		# Syntax for coordinates is as follows:
		#
		# [[x, y], [x_offset, y_offset], z_level, parent]
		#
		# x and y are reletive to the parent. (see below)
		#
		# The offsets are "percentages" from 0 to 1, so 0.5 is the center,
		# 0 is the top or left, and 1 is the bottom or right.
		#
		# z_level should be self explanitory.
		#
		# parent is the object that the object is relative to.
		# If you exclude a parent, the parent will be the chipmunk body.
		#
		parts = {
			:head => [[2.0,93.0],[0.5,1.7], 3],
			:torso => [[0.0,90.0],[0.5,0.5], 2],

			:upper_right_arm => [[-6,107],[0.42,0.3], 3],
			:upper_left_arm => [[1,107],[0.42,0.3], 1],
			:lower_right_arm => [[-26,11],[0.3,0.1], 4, :upper_right_arm],
			:lower_left_arm => [[-26,11],[0.3,0.1], 1, :upper_left_arm],

			:upper_right_leg => [[0,55],[0.5,0.3], 3],
			:upper_left_leg => [[5,57],[0.5,0.3], 1],
			:lower_right_leg => [[-30,4],[0.8,0.25], 4, :upper_right_leg],
			:lower_left_leg => [[-30,4],[0.8,0.25], 2, :upper_left_leg],

			:right_foot => [[-30,25],[0.5,0.5], 5, :lower_right_leg],
			:left_foot => [[-30,25],[0.5,0.5], 3, :lower_left_leg],
		}

		load_parts parts

		animation :walking, :standing do
			duration 700
			animate(:head) { range(-2..3) }

			animate :gun do
				range(90..90)
			end
		end

		animation :walking do
			easing :quart

			animate :upper_right_arm, :upper_left_arm do
				range(-50..45)
				inverse
			end

			animate :lower_right_arm, :lower_left_arm do
				range(-50..-16)
				inverse
			end

			animate :upper_right_leg, :upper_left_leg do
				range(-30..20)
				inverse
			end

			animate :lower_right_leg, :lower_left_leg do
				range(0..40)
				inverse# :alternate
			end
		end

		animation :standing do
			animate :upper_right_arm, :upper_left_arm do
				range(-20..-18)
			end

			animate :lower_right_arm, :lower_left_arm do
				range(-60..-50)
				inverse
			end

			animate :upper_right_leg, :upper_left_leg do
				range(0..0)
			end

			animate :lower_right_leg, :lower_left_leg do
				range(0..0)
			end
		end

		@animator.group = :standing

		# Add new parts on-the-fly. TODO: Move this to the gun pickup event.

		new_parts = {
			:gun => [[0,0],[0.0,0.9], 10, :lower_right_arm],
		}

		load_parts new_parts
	end

	def update
		if @body.vel.x > 5 or @body.vel.x < -5
			@animator.group = :walking
		else
			@animator.group = :standing
		end
		super
	end

	def collect(item)
		@backpack << item
	end

	def drop
		item = @backpack.pop

		if item
			item.reset @torso.body.pos + vec2(140 * facing_sign, -50)
			@screen.map.items.insert item
		end
	end

	def shoot
		item = @backpack.pop

		if item
			m = vec2(@screen.mouse_x + @screen.camera.x, @screen.mouse_y + @screen.camera.y + 70) - @torso.body.pos

			r = 200.0 # constant pull strength, not based on mouse distance
			t = Math::atan2(m.x, m.y)
			fv = vec2(r * Math::sin(t), r * Math::cos(t))

			launch_point = @torso.body.pos + vec2(90 * facing_sign, -70)

			# @screen.draw_line(@screen.mouse_x, @screen.mouse_y, 0xffff0000, launch_point.x-@screen.camera.x, launch_point.y-@screen.camera.y, 0xffff0000, 1000)

			item.reset launch_point
			item.shape.body.apply_impulse(fv, vec2(0, 0))
			@screen.map.items.insert item
		end
	end
end
