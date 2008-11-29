require 'character'

class Player < Character
	def initialize(window, position=Screen::Center)
		super(window, position)

		# The collision_type of a shape allows us to set up special collision behavior
		# based on these types. The actual value for the collision_type is arbitrary
		# and, as long as it is consistent, will work for us; of course, it helps to have it make sense
		@shape.collision_type = :player

		parts = {
			:head => [[0.0,0.0],[0.5,1.7], 3],
			:torso => [[0.0,0.0],[0.5,0.5], 2],

			:upper_right_arm => [[-14,27],[0.42,0.3], 3],
			:upper_left_arm => [[-14,27],[0.42,0.3], 1],
			:lower_right_arm => [[-52,2],[0.7,0.3], 4, :upper_right_arm],
			:lower_left_arm => [[-52,2],[0.7,0.3], 1, :upper_left_arm],

			:upper_right_leg => [[0,-45],[0.5,0.3], 3],
			:upper_left_leg => [[0,-45],[0.5,0.3], 1],
			:lower_right_leg => [[-45,10],[0.7,0.25], 4, :upper_right_leg],
			:lower_left_leg => [[-45,10],[0.7,0.25], 2, :upper_left_leg],


			:right_foot => [[-60,45],[0.5,0.5], 5, :lower_right_leg],
			:left_foot => [[-60,45],[0.5,0.5], 5, :lower_left_leg],
		}

		load_parts parts
	end
end

