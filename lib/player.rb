require 'character'

class Player < Character
	def initialize(window, position=Screen::Center)
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
			:head => [[2.0,3.0],[0.5,1.7], 3],
			:torso => [[0.0,0.0],[0.5,0.5], 2],

			:upper_right_arm => [[-6,17],[0.42,0.3], 3],
			:upper_left_arm => [[1,17],[0.42,0.3], 1],
			:lower_right_arm => [[-26,11],[0.3,0.1], 4, :upper_right_arm],
			:lower_left_arm => [[-26,11],[0.3,0.1], 1, :upper_left_arm],

			:upper_right_leg => [[0,-35],[0.5,0.3], 3],
			:upper_left_leg => [[5,-33],[0.5,0.3], 1],
			:lower_right_leg => [[-30,4],[0.8,0.25], 4, :upper_right_leg],
			:lower_left_leg => [[-30,4],[0.8,0.25], 2, :upper_left_leg],


			:right_foot => [[-30,25],[0.5,0.5], 5, :lower_right_leg],
			:left_foot => [[-30,25],[0.5,0.5], 3, :lower_left_leg],
		}

		load_parts parts
	end

	def animate(part)
		case part

		when :upper_right_arm
			angle = 55 * Math.sin(milliseconds / 300.0)
		when :upper_left_arm
			angle = 55 * -Math.sin(milliseconds / 300.0)

		when :lower_right_arm
			angle = 20 * Math.sin(milliseconds / 300.0) - 40
		when :lower_left_arm
			angle = 20 * -Math.sin(milliseconds / 300.0) - 40

		when :upper_right_leg
			angle = 15 * Math.sin(milliseconds / 300.0) - 5
		when :upper_left_leg
			angle = 15 * -Math.sin(milliseconds / 300.0) - 5

		when :lower_right_leg
			angle = 15 * Math.sin(milliseconds / 300.0) + 5
		when :lower_left_leg
			angle = 15 * -Math.sin(milliseconds / 300.0) + 5

		when :head
			angle = 5 * Math.sin(milliseconds / 300.0)

		else
			angle = 0
		end

		angle
	end
end

