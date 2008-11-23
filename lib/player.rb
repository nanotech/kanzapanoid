class Player
	attr_reader :shape

	def initialize(window, position=Screen::Center)
		@window = window

		# Create the Body for the Player
		body = CP::Body.new(10.0, 1500.0)

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
		@shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

		# The collision_type of a shape allows us to set up special collision behavior
		# based on these types.  The actual value for the collision_type is arbitrary
		# and, as long as it is consistent, will work for us; of course, it helps to have it make sense
		@shape.collision_type = :player

		# Set up physical properties
		@shape.body.p = position
		@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
		@shape.u = 1.0 # friction

		# Add the Player to Space
		body.add_to_space(@window.space)
		@shape.add_to_space(@window.space)

		@dir = :left
		@vy = 0 # Vertical velocity
		@map = window.map

		# Load all animation frames
		@standing, @walk1, @walk2, @jump =
			*Image.load_tiles(window, "media/CptnRuby.png", 50, 50, false)
		# This always points to the frame that is currently drawn.
		# This is set in update, and used in draw.
		@cur_image = @standing

		# Keep in mind that down the screen is positive y, which means that PI/2 radians,
		# which you might consider the top in the traditional Trig unit circle sense is actually
		# the bottom; thus 3PI/2 is the top
		@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen
	end

	def draw(screen_x, screen_y)
		# Flip vertically when facing to the left.
		if @shape.body.v.x > 0
			offs_x = -25
			factor = 1.0
		else
			offs_x = 25
			factor = -1.0
		end
		#@cur_image.draw(@x - screen_x + offs_x, @y - screen_y - 49, 0, factor, 1.0)

		#@cur_image.draw_rot(@shape.body.p.x, @shape.body.p.y, ZOrder::Player, @shape.body.a * 180.0 / Math::PI + 90)
		@cur_image.draw_rot(
			@shape.body.p.x - @window.camera_x,
			@shape.body.p.y - @window.camera_y,
			ZOrder::Player,
			@shape.body.a * 180.0 / Math::PI + 90
		)
	end

	def update
		# Select image depending on action
		if !@window.button_down? Gosu::KbLeft and !@window.button_down? Gosu::KbRight
			@cur_image = @standing
		else
			@cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
		end
		if @shape.body.v.y < 0
			@cur_image = @jump
		end
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

	def spin_left; @shape.body.t -= 10000.0/SUBSTEPS end
	def spin_right; @shape.body.t += 10000.0/SUBSTEPS end

	def jump
		#@shape.body.apply_force((@shape.body.a.radians_to_vec2 * (3000.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
		@shape.body.apply_impulse(CP::Vec2.new(0, -15) * (20.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end

	def duck
		#@shape.body.apply_force(-(@shape.body.a.radians_to_vec2 * (3000.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
		@shape.body.apply_force(CP::Vec2.new(0, 15) * (300.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end

	def stop; @shape.surface_v = CP::Vec2.new(0,0) end
end

