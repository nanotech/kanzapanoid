require 'yaml'
require 'items'

class VectorMap
	attr_accessor :layers, :polys, :poly, :line, :items, :screen

	def initialize(screen, editorMode = false)
		@screen = screen
		@editorMode = editorMode
		@layers = []
		@polys = []
		@poly = []
		@line = []
		@items = Items.new self
		@zincrement = 1
	end

	def draw(editor=nil)
		layerZ = ZOrder::Background
		@layers.each do |layer|
			layer.draw(-@screen.window.camera.x, -@screen.window.camera.y, layerZ)

			# Increase the z-level for each layer.
			# This should be implemented in a more flexible way
			# some time in the future.
			layerZ += @zincrement
		end

		@polys.each { |p| p.draw editor } if editor
		@items.draw
	end

	module ParseMode
		None = 0
		ChipmunkPoly = 1 # for the actual game
		EditorPoly = 2 # for the editor
	end

	module FileNames
		Folder = 'maps/'
		Vectors = 'vectors.yml'
		Layers = 'layer'
	end

	def open(mapName)
		@mapFolder = FileNames::Folder + mapName + '/'
		@vectorFile = @mapFolder + FileNames::Vectors

		# If we're in editor mode, get rid of the old map.
		# This will also need to be implemented for the
		# game for level switching.
		if @editorMode == true 
			@polys.clear 
			@items = nil
		end
		# Get rid of old layers
		@layers.clear

		if File.exists? @mapFolder
			Dir.foreach(@mapFolder) do |f|
				if f.include? FileNames::Layers
					@layers.push Gosu::Image.new(@screen.window, @mapFolder + f, true)
				end
			end
		end

		body = CP::Body.new(Float::INFINITY, Float::INFINITY) if @editorMode == false

		if File.exists? @vectorFile
			data = []

			File.open(@vectorFile) do |yf|
				YAML.load_documents(yf) do |ydoc|
					# ydoc contains the single object
					# from the YAML document
					data << ydoc
				end
			end

			@polys = data[0]
			@items = Items.new self
			@items.items = data[1]

			if @editorMode == false
				@polys.each do |poly|
					@cp_vertices = []
					poly.vertices.each_index do |vertex|
						@cp_vertices[vertex] = CP::Vec2.new(*poly.vertices[vertex])
					end

					shape = CP::Shape::Poly.new(body, @cp_vertices, CP::Vec2.new(0,0))
					shape.u = 0.5 # friction
					@screen.space.add_static_shape(shape)
				end
			end

		# Backwards compatability code.
		elsif File.exists? @mapFolder + 'vectors.txt'
			mode = ParseMode::None
			vertices = []
			# Read entire file, stripping surrounding white space on each line.
			lines = File.readlines(@mapFolder + 'vectors.txt').map { |line| line.chop }

			lines.each do |line|
				oldmode = mode
				if line == 'poly' 
					if @editorMode == true
						mode = ParseMode::EditorPoly
					else
						mode = ParseMode::ChipmunkPoly
					end

					vertices.clear
				end

				if line == 'end'
					if mode == ParseMode::EditorPoly
						open_poly = new_poly

						vertices.each do |vertex|
							open_poly.add_vertex(vertex[0], vertex[1])
						end
					end

					if mode == ParseMode::ChipmunkPoly
						shape = CP::Shape::Poly.new(body, vertices, CP::Vec2.new(0,0))
						shape.u = 0.5 # friction
						@screen.space.add_static_shape(shape)
					end

					mode = ParseMode::None
				end

				# If we didn't change modes, that means should read
				# this line and convert it into a usable format.
				if mode == oldmode
					vertices.push line.split.map { |x| x.to_f } if mode == ParseMode::EditorPoly
					vertices.push line.to_vec2 if mode == ParseMode::ChipmunkPoly
				end

			end # line loop
		end # file exists
	end

	def save
		# Create a folder for the map if it doesn't exist
		if !File.directory? @mapFolder then Dir.mkdir @mapFolder end

		yaml = @polys.to_yaml
		yaml << @items.items.to_yaml

		# Write to disk
		File.open(@vectorFile, 'w') { |f| f.write(yaml) }
	end

	def new_poly
		@polys.push Polygon.new
		@polys.last
	end
end

class Polygon
	attr_accessor :vertices

	def initialize(vertices=[])
		@vertices = vertices
	end

	def draw(editor)
		if self == editor.open_poly
			color = LineColor::Active
		else
			color = LineColor::Inactive
		end

		window = editor.window

		@vertices.each_index do |id|
			window.draw_line(@vertices[id - 1][0] - window.camera_x,
							 @vertices[id - 1][1] - window.camera_y, color,
							 @vertices[id][0] - window.camera_x,
							 @vertices[id][1] - window.camera_y, color,
							 ZOrder::Lines)
		end
	end

	def add_vertex(x, y)
		@vertices.push [x, y]
	end

    def to_yaml_type; '!kanzapanoid.nanotechcorp.net,2008-12-08/polygon'; end

	def to_yaml(opts = {})
		YAML::quick_emit(self, opts) do |out|
			out.seq(taguri, to_yaml_style) do |seq|
				@vertices.each do |vertex|
					seq.add("#{vertex[0]} #{vertex[1]}")
				end
			end
		end
	end
end

YAML::add_domain_type('kanzapanoid.nanotechcorp.net,2008-12-08', 'polygon') do |type, val|
	vertices = []
	val.each do |vertex|
		 vertex = vertex.split
		 vertex[0] = vertex[0].to_f
		 vertex[1] = vertex[1].to_f
		 vertices << vertex
	end
	Polygon.new(vertices)
end
