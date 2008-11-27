class VectorMap
	attr_accessor :layers, :polys, :poly, :line

	def initialize(window, editorMode = false)
		@window = window
		@editorMode = editorMode
		@layers = []
		@polys = []
		@poly = []
		@line = []
		@zincrement = 1
	end

	def draw
		layerZ = ZOrder::Background
		@layers.each do |layer|
			layer.draw(-@window.camera_x, -@window.camera_y, layerZ)

			# Increase the z-level for each layer.
			# This should be implemented in a more flexible way
			# some time in the future.
			layerZ += @zincrement
		end
	end

	module ParseMode
		None = 0
		ChipmunkPoly = 1 # for the actual game
		EditorPoly = 2 # for the editor
	end

	module FileNames
		Folder = 'maps/'
		Vectors = 'vectors.txt'
	end

	def open(mapName)
		@mapFolder = FileNames::Folder + mapName + '/'
		@vectorFile = @mapFolder + FileNames::Vectors

		# If we're in editor mode, get rid of the old map.
		# This will also need to be implemented for the
		# game for level switching.
		@polys.clear if @editorMode == true 
		# Get rid of old layers
		@layers.clear

		if File.exists? @mapFolder
			Dir.foreach(@mapFolder) do |f|
				if f.include? 'layer'
					@layers.push Gosu::Image.new(@window, @mapFolder + f, true)
				end
			end
		end

		if File.exists? @vectorFile
			# Read entire file, stripping surrounding white space on each line.
			lines = File.readlines(@vectorFile).map { |line| line.chop }

			vertices = []

			mode = ParseMode::None
			body = CP::Body.new(1.0/0.0, 1.0/0.0) if @editorMode == false

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
						newVertices = []

						many = vertices.size
						many.times do |i|
							if i == many
								newVertices.push [vertices[i], vertices[i+1]]
							else
								newVertices.push [vertices[i], vertices[i-1]]
							end
						end

						@polys.push newVertices
					end

					if mode == ParseMode::ChipmunkPoly
						shape = CP::Shape::Poly.new(body, vertices, CP::Vec2.new(0,0))
						shape.u = 0.5 # friction
						@window.space.add_static_shape(shape)
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
		data = ''

		@polys.each do |poly|
			data << "poly\n"

			poly.each do |line|
				# This converts from lines to vertices
				# and adds it to the data string.
				data << "#{line[0][0]} #{line[0][1]}\n"
			end

			data << "end\n"
		end

		data << "\n"

		# Create a folder for the map if it doesn't exist
		if !File.directory? @mapFolder then Dir.mkdir @mapFolder end

		# Write to disk
		File.open(@vectorFile, 'w') { |f| f.write(data) }
	end
end
