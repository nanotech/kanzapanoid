require 'character'

class Player < Character
	def initialize(window, position=window.center)
		super(window, position)

		# The collision_type of a shape allows us to set up special collision behavior
		# based on these types. The actual value for the collision_type is arbitrary
		# and, as long as it is consistent, will work for us; of course, it helps to have it make sense
		@shape.collision_type = :player

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
			:head => [[2.0,103.0],[0.5,1.7], 3],
			:torso => [[0.0,100.0],[0.5,0.5], 2],

			:upper_right_arm => [[-6,117],[0.42,0.3], 3],
			:upper_left_arm => [[1,117],[0.42,0.3], 1],
			:lower_right_arm => [[-26,11],[0.3,0.1], 4, :upper_right_arm],
			:lower_left_arm => [[-26,11],[0.3,0.1], 1, :upper_left_arm],

			:upper_right_leg => [[0,65],[0.5,0.3], 3],
			:upper_left_leg => [[5,67],[0.5,0.3], 1],
			:lower_right_leg => [[-30,4],[0.8,0.25], 4, :upper_right_leg],
			:lower_left_leg => [[-30,4],[0.8,0.25], 2, :upper_left_leg],


			:right_foot => [[-30,25],[0.5,0.5], 5, :lower_right_leg],
			:left_foot => [[-30,25],[0.5,0.5], 3, :lower_left_leg],
		}

		load_parts parts

		animation :walking, :standing do
			duration 700
			animate(:head) { range(-2..3) }
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
				inverse :alternate
			end
		end

		animation :standing do
			animate :upper_right_arm, :upper_left_arm do
				range(-10..15)
			end

			animate :lower_right_arm, :lower_left_arm do
				range(-50..-16)
			end

			animate :upper_right_leg, :upper_left_leg do
				range(-5..5)
				inverse
			end

			animate :lower_right_leg, :lower_left_leg do
				range(0..5)
			end
		end

		@animation.group = :walking
	end
end
