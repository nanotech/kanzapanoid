#!/usr/bin/ruby
begin
	# In case you use Gosu via rubygems.
	require 'rubygems'
rescue LoadError
	# In case you don't.
end

require 'gosu'
include Gosu

module Screen
	Width = 640
	Height = 480
end

$LOAD_PATH.push 'lib/'
require 'helpers'
require 'vectormap'
require 'items'
require 'collectible_gem'
require 'text_field'

# Layering of sprites
module ZOrder
	Background, Items, Lines, Vertices, UI = 0, 20, 40, 50, 100
end

class Editor < Gosu::Window
	attr_reader :map_file, :layers
	attr_accessor :space, :camera_x, :camera_y

	MAP_EDITOR = true

	def initialize
		super(Screen::Width, Screen::Height, false)
		self.caption = "Kanzapanoid Map Editor"

		# Create our Space and set its damping and gravity
		@space = CP::Space.new
		@space.damping = 0.8
		@space.gravity = CP::Vec2.new(0.0, 0.0)

		# Scrolling is stored as the position of the top left corner of the screen.
		@camera_x, @camera_y = 0,0

		@mode = 0
		@mouseColors = [0xff999999, 0xff00ff00, 0xff0000ff, 0xffff0000]

		@map_file = ''

		@editor = MapEditor.new self
		@input = TextField.new self, [10,10], Screen::Width - 20, 'Map Name?'
	end

	# Detects arrow key presses and moves the camera
	# when a key is pressed.
	def update
		if button_down? Gosu::KbLeft then @camera_x -= 10 end
		if button_down? Gosu::KbRight then @camera_x += 10 end
		if button_down? Gosu::KbUp then @camera_y -= 10 end
		if button_down? Gosu::KbDown then @camera_y += 10 end
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

		# Global
		if id == Gosu::KbEscape then close end
		if id == self.char_to_button_id('s') then @editor.map.save end

		case @mode

		# Polygons
		when 1
			if id == Gosu::MsLeft
				@editor.add_vertex(mouse_x + camera_x, mouse_y + camera_y) 
			end
			if id == Gosu::MsRight then @editor.undo_line end
			if id == self.char_to_button_id('c') then @editor.close_poly end
			if id == self.char_to_button_id('u') then @editor.undo_poly end

		# Items
		when 2
			if id == Gosu::MsLeft
				@editor.add_item(mouse_x + camera_x, mouse_y + camera_y)
			end
			if id == self.char_to_button_id('u') then @editor.undo_item end

		# Map name text field
		when 0
			if id == Gosu::KbEscape then
				# Escape key will not be 'eaten' by text fields; use for deselecting.
				if self.text_input then
					self.text_input = nil
				else
					close
				end
			elsif id == Gosu::MsLeft then
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
			elsif id == Gosu::KbReturn
				@map_file = self.text_input.text if self.text_input
				@editor.map.open @map_file
				self.text_input = nil 
			end
		end

		# Cycle though the modes
		if id == Gosu::KbReturn
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
		@map = VectorMap.new window, true
		@open_poly = nil
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
	end

	def add_vertex(x, y)
		if !@open_poly
			@open_poly = @map.new_poly
		end

		@open_poly.add_vertex(x, y)
	end

	def add_item(x, y)
		@map.items.add CollectibleGem.new(@window, CP::Vec2.new(x,y))
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

