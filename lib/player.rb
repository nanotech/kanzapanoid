require 'character'

class Player < Character
	def initialize(window, position=Screen::Center)
		super(window, position)

		# The collision_type of a shape allows us to set up special collision behavior
		# based on these types. The actual value for the collision_type is arbitrary
		# and, as long as it is consistent, will work for us; of course, it helps to have it make sense
		@shape.collision_type = :player

		parts = {
			:head => [[0.0,0.0],[0.5,1.7]],
			:torso => [[0.0,0.0],[0.5,0.5]],
			:upper_right_arm => [[-14,27],[0.42,0.3]]
		}

		load_parts parts
	end
end

