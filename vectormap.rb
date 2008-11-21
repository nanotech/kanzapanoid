class String
	def to_vec2
		vertex = self.split
		CP::Vec2.new(vertex[0].to_f, vertex[1].to_f)
	end
end

class VectorMap
	attr_accessor :layers, :polys, :poly, :line

	def initialize(window, editorMode = false)
		@window = window
		@editorMode = editorMode
		@layers, @polys, @poly, @line = [], [], [], []
		@zincrement = 1
	end

	def draw
		layerZ = ZOrder::Background
		@layers.each do |layer|
			layer.draw(-@window.camera_x, -@window.camera_y, layerZ)
			layerZ += @zincrement
		end
	end

	module ParseMode
		None = 0
		ChipmunkPoly = 1
		EditorPoly = 2
	end

	module FileNames
		Folder = 'maps/'
		Vectors = 'vectors.txt'
	end

	def open(mapName)
		@mapFolder = FileNames::Folder + mapName + '/'
		@vectorFile = @mapFolder + FileNames::Vectors

		@polys.clear if @editorMode == true 
		@layers.clear

		if File.exists? @mapFolder
			Dir.foreach(@mapFolder) do |f|
				if f.include? 'layer'
					@layers.push Gosu::Image.new(@window, @mapFolder + f, true)
				end
			end
		end

		if File.exists? @vectorFile
			lines = File.readlines(@vectorFile).map { |line| line.chop }

			vertices = []

			mode = ParseMode::None
			body = CP::Body.new(8**10, 8**10) if @editorMode == false

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
						@window.space.add_static_shape(shape)
					end

					mode = ParseMode::None 
				end

				if mode == oldmode
					vertices.push line.split.map { |x| x.to_f } if mode == ParseMode::EditorPoly
					vertices.push line.to_vec2 if mode == ParseMode::ChipmunkPoly
				end

			end # line loop
		end # file exists

		@window.space.add_body(body) if @editorMode == false
	end

	def save
		data = ''

		@polys.each do |poly|
			data << "poly\n"
			first = true
			poly.each do |line|
				data << "#{line[0][0]} #{line[0][1]}\n"
			end
			data << "end\n"
		end

		data << "\n"

		if !File.directory? @mapFolder then Dir.mkdir @mapFolder end
		File.open(@vectorFile, 'w') { |f| f.write(data) }
	end
end
