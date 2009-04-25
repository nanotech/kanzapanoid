#!/usr/bin/ruby
Dir.chdir '..'
$LOAD_PATH.push 'lib/'

require 'chipmunk'
include CP

class ImpulseTest < Window
	attr_reader :space

	def initialize
		@width = 800
		@height = 600
		super(800, 600, false)

		# Create our Space and set its damping and gravity
		@space = Space.new
		@space.damping = 0.8
		@space.gravity = Vec2.new(2.0, 0.0)

		# Time increment over which to apply a physics "step" ("delta t")
		@dt = (1.0/60.0)

		shape_array = [
			CP::Vec2.new(-29, -29), # bottom left
			CP::Vec2.new(-29, 29), # bottom right
			CP::Vec2.new(29, 29), # top right
			CP::Vec2.new(29, -29) # top left
		]

		mass = 5
		inertia = CP.moment_for_poly(mass, shape_array, CP::Vec2.new(0,0))

		body = CP::Body.new(mass, inertia)
		shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

		@image = Gosu::Image.new(self, 'items/metal_box/metal_box.png', false)

		@shape = shape
		@shape.body.p = vec2(@width/2, @height/2)
		#@shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
		#@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen

		@space.add_shape(@shape)
		@space.add_body(body)

		@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
	end

	def update
		@space.step(@dt)
	end

	def draw
		@image.draw_rot(@shape.body.pos.x, @shape.body.pos.y, 10, @shape.body.a)

		draw_line(mouse_x, mouse_y, 0xffffffff, mouse_x + 10, mouse_y + 10, 0xff99ff99, 10)
	end

	def button_down(id)
		if id == KbEscape then close end
		if id == MsLeft
			m = vec2(mouse_x-@shape.body.pos.x, mouse_y-@shape.body.pos.y)
			r = Math::hypot(m.x, m.y)
			t = Math::atan2(m.x, m.y)

			r = 300.0 # constant pull strength, not based on mouse distance

			fv = vec2(r * Math::sin(t), r * Math::cos(t))

			draw_line(mouse_x, mouse_y, 0xffff0000, @shape.body.pos.x, @shape.body.pos.y, 0xffff0000, 1000)

			@shape.body.apply_impulse(fv, vec2(0, 0))
		end
	end
end

ImpulseTest.new.show
