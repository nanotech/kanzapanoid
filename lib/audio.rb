class Audio
	def initialize(window, file=false)
		@window = window
		@audio_folder = 'media/'
		@audio_format = '.ogg'

		@samples = []
		@playing = []

		if file then self.load file, true end
	end

	def load(file, loop=false)
		main_file = @audio_folder + file + @audio_format

		sample = Gosu::Sample.new(@window, main_file)
		data = {
			:main => sample,
			:loop => true
		}
		@samples.push data

		sample_id = @samples.size - 1

		if loop 
			intro_file = @audio_folder + file + '_intro' + @audio_format
			if File.exists? intro_file
				@samples[sample_id][:intro] = Gosu::Sample.new(@window, intro_file)
			end

			play sample_id 
		end

		sample_id
	end

	def play(id)
		if @samples[id][:loop] and !@samples[id][:begun]
			@playing.push [@samples[id][:intro].play, id]
			@samples[id][:begun] = true
		else
			@playing.push [@samples[id][:main].play, id]
		end
	end

	def update
		@playing.each do |a|
			if !a[0].playing?
				id = a[1]
				@playing.delete a
				play id
			end
		end
	end
end

