class Character
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

		# Set up physical properties
		@shape.body.p = position
		@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
		@shape.u = 1.0 # friction

		# Add the Player to Space
		body.add_to_space(@window.space)
		@shape.add_to_space(@window.space)

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

		@body_parts = []
		@part_images = {}
	end

	def draw(screen_x, screen_y)
=begin
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
=end

		i = 0
		@body_parts.each do |part, coords|
			zorder = (part == 'torso') ? ZOrder::Player + 5 : ZOrder::Player + i
			if part == :upper_right_arm
				swing = 35 * Math.sin(milliseconds / 300.0)
			else
				swing = 0
			end

			angle = @shape.body.a.radians_to_gosu
			
			offset = coords[0]
			origin = coords[1]

			offset_distance = offset[0].distance_to offset[1]
			if (offset[0] and offset[1]) != 0
				offset_angle = Math::sin(offset[0] / offset[1]) / (180.0 / Math::PI)
			else
				offset_angle = 0
			end

			angle_offset_x = offset_distance * Math::cos(angle.gosu_to_radians - offset_angle)
			angle_offset_y = offset_distance * Math::sin(angle.gosu_to_radians - offset_angle)

			if @blah == nil
				@blah = 0
			end
			if @blah < 1 and angle_offset_x != 0
				p part
				p offset[0]
				p offset[1]
				p offset[0]**2 + offset[1]**2
				p offset_angle
				p Math::cos(angle.gosu_to_radians - offset_angle)
				p angle_offset_x
				p angle_offset_y
				@blah += 1
			end

			@part_images[part].draw_rot(
				@shape.body.p.x - @window.camera_x - angle_offset_x,
				@shape.body.p.y - @window.camera_y + angle_offset_y,
				zorder,
				@shape.body.a.radians_to_gosu + swing,
				origin[0], origin[1]
			)
			i += 1
		end
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

	def load_parts(parts)
		parts.each do |part, coords|
			@part_images[part] = Image.new(@window, 'media/' + self.class.name.downcase + '/' + part.to_s + '.png', true)
		end

		@body_parts = parts
	end

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

