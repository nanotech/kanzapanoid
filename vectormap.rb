class String
	def to_vec2
		vertex = self.split
		CP::Vec2.new(vertex[0].to_f, vertex[1].to_f)
	end
end

class VectorMap
	module ParseMode
		None = 0
		Poly = 1
	end

	def initialize(window, mapfile)
		@window = window
		@space = window.space

		lines = File.readlines(mapfile).map { |line| line.chop }

		shapes = []
		vertices = []

		mode = ParseMode::None

		body = CP::Body.new(8**10, 8**10)

		lines.each do |line|
			oldmode = mode
			if line == 'poly' 
				mode = ParseMode::Poly
				vertices.clear
			end

			if line == 'end'
				if mode == ParseMode::Poly
					shape = CP::Shape::Poly.new(body, vertices, CP::Vec2.new(0,0))
					@space.add_static_shape(shape)
				end

				mode = ParseMode::None 
			end

			if mode == oldmode
				if mode == ParseMode::Poly
					vertices.push line.to_vec2
				end
			end
		end

		@space.add_body(body)
	end
end
