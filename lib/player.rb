require 'character'

class Player < Character
	def initialize(window, position=Screen::Center)
		super(window, position)

		# The collision_type of a shape allows us to set up special collision behavior
		# based on these types. The actual value for the collision_type is arbitrary
		# and, as long as it is consistent, will work for us; of course, it helps to have it make sense
		@shape.collision_type = :player

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
end

