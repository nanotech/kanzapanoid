class World
	def initialize(window)
		@window = window
		@space = window.space

		@zincrement = 1

		@layers = []
		@layers.push Image.new(window, "media/kanzapanoid_sky.png", true)
		@layers.push Image.new(window, "maps/test/layer1.png", true)
	end

	def draw(camera_x, camera_y)
		layerZ = 0
		@layers.each do |layer|
			layer.draw(-camera_x, -camera_y, ZOrder::Background + layerZ)
			layerZ += @zincrement
		end
	end
end

