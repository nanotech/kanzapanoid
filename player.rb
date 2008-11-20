class Player
	attr_reader :shape

	def initialize(window, shape, position)
		@shape = shape
		@shape.body.p = position
		@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity

		@dir = :left
		@vy = 0 # Vertical velocity
		@map = window.map

		# Load all animation frames
		@standing, @walk1, @walk2, @jump =
			*Image.load_tiles(window, "media/CptnRuby.png", TILE_SIZE, TILE_SIZE, false)
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
		#if @dir == :left then
			#offs_x = -25
			#factor = 1.0
		#else
			#offs_x = 25
			#factor = -1.0
		#end
		#@cur_image.draw(@x - screen_x + offs_x, @y - screen_y - 49, 0, factor, 1.0)

		#@cur_image.draw_rot(@shape.body.p.x, @shape.body.p.y, ZOrder::Player, @shape.body.a * 180.0 / Math::PI + 90)
		@cur_image.draw_rot(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, ZOrder::Player, @shape.body.a * 180.0 / Math::PI + 90)
	end

	def update(move_x, move_y)
		# Select image depending on action
		if (move_x == 0)
			@cur_image = @standing
		else
			@cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
		end
		if (@vy < 0)
			@cur_image = @jump
		end
	end

	# Directly set the position of our Player
	def warp(vect)
		@shape.body.p = vect
	end

	def move_left
		#@shape.body.t -= 300.0/SUBSTEPS
		@shape.body.apply_force(CP::Vec2.new(-5, 0) * (300.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end

	def move_right
		#@shape.body.t += 300.0/SUBSTEPS
		@shape.body.apply_force(CP::Vec2.new(5, 0) * (300.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end

	def jump
		#@shape.body.apply_force((@shape.body.a.radians_to_vec2 * (3000.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
		@shape.body.apply_force(CP::Vec2.new(0, -5) * (300.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end

	def duck
		#@shape.body.apply_force(-(@shape.body.a.radians_to_vec2 * (3000.0/SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
		@shape.body.apply_force(CP::Vec2.new(0, 5) * (300.0/SUBSTEPS), CP::Vec2.new(0.0, 0.0))
	end
end

