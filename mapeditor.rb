#!/usr/bin/env ruby

#
# Map Editor entry point
#

$LOAD_PATH.push 'lib/'

require 'screen'
require 'audio'

require 'chipmunk'
include CP

require 'text_field'
require 'vectormap'

# Layering of sprites
module ZOrder
	Background, Items, Lines, Vertices, UI = 0, 20, 40, 50, 100
end

module Mode
	None = 0
	Polygons = 1
	Items = 2
end

class Editor < Screen
	attr_reader :map_file, :layers
	attr_accessor :space, :mode

	MAP_EDITOR = true

	def initialize
		super('Kanzapanoid Map Editor')

		# Create our Space and set its damping and gravity
		@space = Space.new
		@space.damping = 0.8
		@space.gravity = Vec2.new(0.0, 0.0)

		@mode = Mode::None
		@mouseColors = [0xff999999, 0xff00ff00, 0xff0000ff, 0xffff0000]

		@map_file = ''

		@editor = MapEditor.new self
		@input = TextField.new self, [10,10], @width - 20, 'Map Name?'
	end

	# Detects arrow key presses and moves the camera
	# when a key is pressed.
	def update
		if button_down? KbLeft then @camera.x -= 10 end
		if button_down? KbRight then @camera.x += 10 end
		if button_down? KbUp then @camera.y -= 10 end
		if button_down? KbDown then @camera.y += 10 end
	end

	# Draws the mouse and calls the drawing 
	# functions of MapEditor and TextField
	def draw
		self.draw_line(mouse_x, mouse_y, @mouseColors[@mode],
					   mouse_x + 20, mouse_y + 20, 0xffffffff,
					   ZOrder::UI + 10)
		@editor.draw
		@input.draw
	end

	# Handles single button press actions such as mouse clicks,
	# undos, saves, etc.
	#
	# Also recognises the editing mode that the user is in and
	# uses the appropriate key mappings for that mode.
	def button_down(id)

		#
		# Global Key Mappings
		#

		super # Default key mappings

		if id == self.char_to_button_id('s') and @mode != Mode::None
			@editor.map.save
		end

		case @mode

		# Polygons
		when Mode::Polygons
			if id == MsLeft
				@editor.add_vertex(mouse_x + camera_x, mouse_y + camera_y) 
			end
			if id == MsRight then @editor.undo_line end
			if id == self.char_to_button_id('c') then @editor.close_poly end
			if id == self.char_to_button_id('u') then @editor.undo_poly end

		# Items
		when Mode::Items
			if id == MsLeft
				@editor.add_item(mouse_x + camera_x, mouse_y + camera_y)
			end
			if id == self.char_to_button_id('u') then @editor.undo_item end
			if id == KbSpace then @editor.switch_tools end

		# Map name text field
		when Mode::None
			if id == KbEscape then
				# Escape key will not be 'eaten' by text fields; use for deselecting.
				if self.text_input then
					self.text_input = nil
				else
					close
				end
			elsif id == MsLeft then
				# Mouse click: Select text field based on mouse position.
				if @input.under_point?(mouse_x, mouse_y)
					self.text_input = @input 
					if self.text_input.text == @input.default_text
						self.text_input.text = ''
					end
				else
					if self.text_input and self.text_input.text == ''
						self.text_input.text = @input.default_text
					end
					self.text_input = nil 
				end
			elsif id == KbReturn
				if self.text_input and @map_file != self.text_input.text
					@map_file = self.text_input.text
					@editor.map.open @map_file
					self.text_input = nil
				end
			end
		end

		# Cycle though the modes
		if id == KbReturn
			if @mode < 2
				@mode += 1
			else
				@mode = 0
			end
		end
	end
end

module LineColor
	Error = 0xffcc3300
	Active = 0xff009933
	Inactive = 0xff0099cc
	Selected = 0xff00ff00
end

class MapEditor
	attr_reader :map, :open_poly, :window

	def initialize(window)
		@window = window
		@map = VectorMap.new @window, true
		@open_poly = nil
		@tool = 0
		@tool_images = []
		switch_tools 0
	end

	def draw
		@map.draw self

		if @open_poly and @open_poly.vertices.last

			# This line goes from the mouse to the last vertex in the poly.
			@window.draw_line(@open_poly.vertices.last[0] - @window.camera_x,
							  @open_poly.vertices.last[1] - @window.camera_y, LineColor::Active,
							  @window.mouse_x, @window.mouse_y, LineColor::Selected,
							  ZOrder::UI)

			# This line goes from the mouse to the first vertex in the poly.
			if @open_poly.vertices[-2]
				@window.draw_line(@open_poly.vertices.first[0] - @window.camera_x,
								  @open_poly.vertices.first[1] - @window.camera_y, LineColor::Active,
								  @window.mouse_x, @window.mouse_y, LineColor::Selected,
								  ZOrder::UI)
			end

			# Draw a line that shows the actual shape of the poly if you close it,
			# but only draw it if there are more than two vertices in the poly.
			if @open_poly.vertices.size > 2
				@window.draw_line(@open_poly.vertices.first[0] - @window.camera_x,
								  @open_poly.vertices.first[1] - @window.camera_y, LineColor::Active,
								  @open_poly.vertices.last[0] - @window.camera_x,
								  @open_poly.vertices.last[1] - @window.camera_y, LineColor::Active,
								  ZOrder::Lines + 1)
			end
		end

		# Draw the Item preview cursor when in Item editing mode
		if @window.mode == Mode::Items
			@tool_images[@tool].draw_rot(@window.mouse_x, @window.mouse_y, ZOrder::UI,
										 0, 0.5, 0.5, 1, 1, 0xccffffff)
		end
	end

	def add_vertex(x, y)
		if !@open_poly
			@open_poly = @map.new_poly
		end

		@open_poly.add_vertex(x, y)
	end

	def add_item(x, y)
		@map.items.add @map.items.available_items[@tool].camelize, [x,y]
	end

	def switch_tools(id=nil)
		if id
			@tool = id
		else
			if @tool < @map.items.available_items.size - 1
				@tool += 1
			else
				@tool = 0
			end
		end

		unless @tool_images[@tool]
			image_file = "items/#{@map.items.available_items[@tool]}/image.png"
			@tool_images[@tool] = Image.new(@window, image_file, false)
		end
	end

	def undo_item
		@map.items.items.pop.destroy
	end

	def undo_line
		@open_poly.vertices.pop if @open_poly
	end

	def undo_poly; @map.polys.pop; end
	def close_poly; @open_poly = nil; end
end

Editor.new.show

