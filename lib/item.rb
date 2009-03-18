class Item
	attr_reader :image, :image_name, :yaml_tag, :shape

	def initialize(screen, position, shape, image=self.class.image_file,
				   yaml_tag=self.class.name, space=screen.space)

		@image_name = image
		@yaml_tag = '-' + yaml_tag
		@space = space

		@window = screen.window

		@image = Gosu::Image.new(@window, image, false)

		position = position.to_vec2 unless position.is_a?(CP::Vec2)

		@shape = shape
		@shape.body.p = position
		@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
		@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen

		create
	end

	def draw(angle=0,z=ZOrder::Items)
		@image.draw_rot(@shape.body.p.x - @window.camera.x,
						@shape.body.p.y - @window.camera.y,
						z, angle)
	end

	def create
		@shape.body.add_to_space(@space)
		@shape.add_to_space(@space)
	end

	def destroy
		@shape.body.remove_from_space(@space)
		@shape.remove_from_space(@space)
	end

	def self.image_file
		"items/#{name.underscore}/#{name.underscore}.png"
	end

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
