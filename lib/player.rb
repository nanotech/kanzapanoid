class Player
	attr_reader :shape

	def initialize(window, position=Screen::Center)
		@window = window

		# Set up the player's body parts
		#@playerParts = %w(head torso upperRightArm lowerRightArm upperRightLeg lowerRightLeg foot)
		@playerParts = %w(
			torso

			upperLeftLeg lowerLeftLeg
			upperLeftArm lowerLeftArm

			upperRightArm lowerRightArm
			upperRightLeg lowerRightLeg

			head
		)
		@playerImages, @playerBodys, @playerShapes = {}, {}, {}

		# In order to create a shape, we must first define it
		# Chipmunk defines 3 types of Shapes: Segments, Circles and Polys
		# We'll use s simple, 4 sided Poly for our Player
		# You need to define the vectors so that the "top" of the Shape is towards 0 radians (the right)
		shape_size = 25.0
		shape_array = [
			CP::Vec2.new(-shape_size, -shape_size), # top left
			CP::Vec2.new(-shape_size, shape_size), # bottom left
			CP::Vec2.new(shape_size, shape_size), # bottom right
			CP::Vec2.new(shape_size, -shape_size) # top right
		]

		# Create the Player's torso
		@playerBodys[:torso] = CP::Body.new(10.0, 150.0)

		# Loop though the list body parts and create them
		@playerParts.each do |part|
			part_sym = part.to_sym

			if part != :torso then @playerBodys[part_sym] = CP::Body.new(1, 15) end
			@playerImages[part_sym] = Image.new(@window, 'media/player/' + part + '.png', true)
			@playerShapes[part_sym] = CP::Shape::Poly.new(@playerBodys[part.to_sym], shape_array, CP::Vec2.new(0,0))
			@playerShapes[part_sym].group = :playerBody
			if part != :torso
				@playerShapes[part_sym].body.p = @playerShapes[:torso].body.local2world(CP::Vec2.new(0,0))
			else
				@playerShapes[:torso].body.p = position
			end
		end

		# The collision_type of a shape allows us to set up special collision behavior
		# based on these types.  The actual value for the collision_type is arbitrary
		# and, as long as it is consistent, will work for us; of course, it helps to have it make sense
		@playerShapes[:torso].collision_type = :player

		# Set up physical properties
		#@playerShapes[:torso].body.v = CP::Vec2.new(0.0, 0.0) # velocity
		@playerShapes[:torso].u = 1.0 # friction

=begin
		torsoBody = @playerShapes[:torso].body

		@playerShapes[:upperRightLeg].body.p =
			torsoBody.local2world(CP::Vec2.new(0,40))
=end

		# Head
		self.join_appendages(@playerBodys[:torso], @playerBodys[:head],
							 70,5, 0,0, 0,0)

		# Upper Right Arm
		self.join_appendages(@playerBodys[:torso], @playerBodys[:upperRightArm],
							 25,-12, 15,-3, -3,1.3)
		# Lower Right Arm
		self.join_appendages(@playerBodys[:upperRightArm], @playerBodys[:lowerRightArm],
							 -25,0, 20,-4, -1.4,0)
		# Upper Right Leg
		self.join_appendages(@playerBodys[:torso], @playerBodys[:upperRightLeg],
							 -48,-5, 15,0, -1,0.8)
		# Lower Right Leg
		self.join_appendages(@playerBodys[:upperRightLeg], @playerBodys[:lowerRightLeg],
							 -25,10, 30,10, 0,1.4)

		# Upper Left Arm
		self.join_appendages(@playerBodys[:torso], @playerBodys[:upperLeftArm],
							 20,5, 15,-5, -3,1.3)
		# Lower Left Arm
		self.join_appendages(@playerBodys[:upperLeftArm], @playerBodys[:lowerLeftArm],
							 -25,0, 20,-4, -1.4,0)
		# Upper Left Leg
		self.join_appendages(@playerBodys[:torso], @playerBodys[:upperLeftLeg],
							 -48,5, 15,0, -1,0.8)
		# Lower Left Leg
		self.join_appendages(@playerBodys[:upperLeftLeg], @playerBodys[:lowerLeftLeg],
							 -25,10, 30,10, 0,1.4)

		CP::Constraint::DampedSpring.new(@playerBodys[:torso], @playerBodys[:upperRightArm],
			CP::Vec2.new(50,30), CP::Vec2.new(0,0),
			1, 1, 1
		).add_to_space(@window.space)

		# Add the Player to Space
		@playerParts.each do |part|
			@playerBodys[part.to_sym].add_to_space(@window.space)
			@playerShapes[part.to_sym].add_to_space(@window.space)
		end

		@map = window.map

		# Keep in mind that down the screen is positive y, which means that PI/2 radians,
		# which you might consider the top in the traditional Trig unit circle sense is actually
		# the bottom; thus 3PI/2 is the top
		@playerShapes[:torso].body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen

		@shape = @playerShapes[:torso]
	end

	def draw(screen_x, screen_y)
		i = 0
		@playerParts.each do |part|
			zorder = (part == 'torso') ? ZOrder::Player + 5 : ZOrder::Player + i
			@playerImages[part.to_sym].draw_rot(
				@playerBodys[part.to_sym].p.x - @window.camera_x,
				@playerBodys[part.to_sym].p.y - @window.camera_y,
				zorder,
				@playerBodys[part.to_sym].a * 180.0 / Math::PI + 90
			)
			i += 1
		end
	end

	def update
	end

	def join_appendages(body_a, body_b, ax1, ay1, ax2, ay2, min, max)
		CP::Constraint::PivotJoint.new(body_a, body_b,
			CP::Vec2.new(ax1,ay1), CP::Vec2.new(ax2,ay2)
		).add_to_space(@window.space)

		CP::Constraint::RotaryLimitJoint.new(body_a, body_b,
			min, max
		).add_to_space(@window.space)
	end

	# Directly set the position of our Player
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

	def spin_left; @shape.body.t -= 50000.0 end
	def spin_right; @shape.body.t += 50000.0 end

	def jump
		#@shape.body.apply_force((@shape.body.a.radians_to_vec2 * (3000.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
		@shape.body.apply_impulse(CP::Vec2.new(0, -10) * (20.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end

	def duck
		#@shape.body.apply_force(-(@shape.body.a.radians_to_vec2 * (3000.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
		@shape.body.apply_force(CP::Vec2.new(0, 10) * (300.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end

	def stop; @shape.surface_v = CP::Vec2.new(0,0) end
end

