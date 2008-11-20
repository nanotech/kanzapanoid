module Tiles
	Grass = 0
	Earth = 1
end

class Map
	attr_reader :width, :height, :gems
	attr_accessor :window

	def initialize(window, filename)
		@window = window
		@space = window.space

		# Load 60x60 tiles, 5px overlap in all four directions.
		@tileset = Image.load_tiles(window, "media/CptnRuby Tileset.png", 60, 60, true)
		@sky = Image.new(window, "media/kanzapanoid_sky.png", true)
		@skyx = 0.0

		gem_img = Image.new(window, "media/CptnRuby Gem.png", false)
		@gems = []

		lines = File.readlines(filename).map { |line| line.chop }
		@height = lines.size
		@width = lines[0].size

		@tiles = Array.new(@width) do |x|
			Array.new(@height) do |y|
				case lines[y][x, 1]
					when '"'
						self.createSolidTile self.tileVector(x, y)
						Tiles::Grass
					when '#'
						self.createSolidTile self.tileVector(x, y)
						Tiles::Earth
					when 'x'
						body = CP::Body.new(0.001, 0.001)
						shape = CP::Shape::Circle.new(body, 25, CP::Vec2.new(0.0, 0.0))
						shape.collision_type = :gem

						@space.add_body(body)
						@space.add_shape(shape)

						location = self.tileVector(x, y)

						@gems.push(CollectibleGem.new(gem_img, shape, location))
						nil
					else
						nil
				end
			end
		end
	end

	def draw(screen_x, screen_y)
		# Sigh, stars!
		@sky.draw(-screen_x, -screen_y, ZOrder::Background)

		# Very primitive drawing function:
		# Draws all the tiles, some off-screen, some on-screen.
		@height.times do |y|
			@width.times do |x|
				tile = @tiles[x][y]
				if tile
					realx = x * TILE_SIZE
					realy = y * TILE_SIZE
					#if realx > (screen_x - 100) and realx < (screen_x + SCREEN_WIDTH) and realy > (screen_y - 100) and realy < (screen_y + SCREEN_HEIGHT)
						# Draw the tile with an offset (tile images have some overlap)
						# Scrolling is implemented here just as in the game objects.
						@tileset[tile].draw(realx - screen_x - 5, realy - screen_y - 5, 0)
					#end
				end
			end
		end
		@gems.each { |c| c.draw(screen_x, screen_y) }
	end

	def tileVector(x, y)
		CP::Vec2.new((x * TILE_SIZE) + (TILE_SIZE / 2), (y * TILE_SIZE) + (TILE_SIZE / 2))
	end

	def createSolidTile(position)
		body = CP::Body.new(100.0**100.0, 100.0**100.0)
		shape_size = TILE_SIZE * 0.6
		shape_array = [
			CP::Vec2.new(-shape_size, -shape_size),
			CP::Vec2.new(-shape_size, shape_size),
			CP::Vec2.new(shape_size, shape_size),
			CP::Vec2.new(shape_size, -shape_size)
		]
		shape = CP::Shape::Poly.new(body, shape_array, position)
		shape.collision_type = :tile

		@space.add_body(body)
		@space.add_static_shape(shape)
	end

	# Solid at a given pixel position?
	def solid?(x, y)
		y < 0 || @tiles[x / TILE_SIZE][y / TILE_SIZE]
	end
end

