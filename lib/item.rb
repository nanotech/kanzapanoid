require 'easing'

#
# An Item is any kind of physical item. Any Item has, at minimum, a containing
# Items object, a Space, a Shape, and an Image.
#
# Item provides Image drawing, Space management, YAML serialization, and
# collision callbacks.
#
class Item
	attr_reader :image, :image_name, :yaml_tag, :shape, :context

	# +context+ is a containing Items object, +position+ is a Vector
	# or Vec2, +shape+ is a CP::Shape, +image+ is a path to an image,
	# +yaml_tag+ is a string to identify the object when serialized,
	# and +space+ is a CP::Space.
	#
	def initialize(context, position, shape, image=self.class.image_file,
				   yaml_tag=self.class.name, space=context.screen.space)

		@image_name = image
		@yaml_tag = '-' + yaml_tag
		@space = space

		@context = context # the Items object that holds this item.
		@window = context.screen.window

		@image = Gosu::Image.new(@window, image, false)

		position = position.to_vec2 unless position.is_a?(CP::Vec2)

		@shape = shape
		@shape.body.p = position

		@shape.collision_type = self.class.name.underscore.to_sym
		@shape.obj = self

		@easer = nil
		@eased = nil

		create
	end

	# Called by the +@context+ when a collision with another object occurs.
	# Override this.
	def collided_with(other)
		@eased = nil
		return false
	end

	def draw
		@image.draw_rot(@shape.body.p.x - @window.camera.x,
						@shape.body.p.y - @window.camera.y,
						ZOrder::Items, angle)
	end

	# The angle to draw the Item at. By default, it's the Item's Body angle.
	def angle
		@shape.body.a
	end

	# Draws the Item's image in icon format. For use in Dashboard and such.
	def draw_icon(x, y, z=ZOrder::Items, animate=false, *args)
		x += @image.width/2
		y += @image.height/2

		if animate
			unless @eased
				@easer = VectorEaser.new(
					[@shape.body.p.x - @context.screen.camera.x, 
						@shape.body.p.y - @context.screen.camera.y],
					:in_out, :expo
				)
				@easer.to [x,y], 2000
				@eased = true
			end

			@easer.update
			x, y = @easer.value.to_a
		end

		@image.draw_rot(x, y, z, angle, *args)
	end

	# Calls destroy, resets the velocity and position of the Item, and then
	# calls create.
	def reset(pos=nil)
		destroy

		# Reset velocity
		@shape.body.vel = Vec2.new(0,0)

		# Move to given position
		@shape.body.pos = pos if pos

		create
	end

	# Adds the Item to it's Space.
	def create
		@shape.body.add_to_space(@space)
		@shape.add_to_space(@space)
	end

	# Removes the Item from it's Space.
	def destroy
		@shape.body.remove_from_space(@space)
		@shape.remove_from_space(@space)
	end

	# The assumed name of the image file.
	def self.image_file
		"items/#{name.underscore}/#{name.underscore}.png"
	end

	# The Item's YAML type.
    def to_yaml_type
		'!kanzapanoid.nanotechcorp.net,2008-12-08/item' + @yaml_tag
	end

	def to_yaml(opts = {})
		YAML::quick_emit(self, opts) do |out|
			out.map(taguri, to_yaml_style) do |map|
				map.add('x', @shape.body.p.x)
				map.add('y', @shape.body.p.y)
				map.add('a', @shape.body.a)
			end
		end
	end

	def self.from_yaml_with(values)
		[values['x'], values['y']]
	end
end

require 'collectible_item'
