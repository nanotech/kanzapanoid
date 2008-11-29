class Audio
	def initialize(window, file=false)
		@window = window
		@audio_folder = 'media/'
		@audio_format = '.ogg'

		@samples = []
		@playing = []

		# If Audio.new was passed a file, load and loop it.
		# Since this is the first loaded file, it's id is 0.
		if file then load file, true; play 0 end
	end

	def load(file, loop=false)
		main_file = @audio_folder + file + @audio_format

		# Load sample and add to the @samples array
		sample = Gosu::Sample.new(@window, main_file)
		data = {
			:main => sample,
			:loop => loop
		}
		@samples.push data

		# Create the sample's id
		sample_id = @samples.size - 1

		if loop 
			# Look for an intro file for looped audio...
			intro_file = @audio_folder + file + '_intro' + @audio_format
			if File.exists? intro_file
				# ...and load it if it exists
				@samples[sample_id][:intro] = Gosu::Sample.new(@window, intro_file)
			end
		end

		sample_id
	end

	def play(id)
		# If the sample has an intro, and hasn't been played before
		if !@samples[id][:begun] and @samples[id][:intro]
			# [0] is the actual sample, while [1] is it's id in @samples.
			@playing.push [@samples[id][:intro].play, id]

			# :begun is set when the intro has been played
			@samples[id][:begun] = true
		else
			@playing.push [@samples[id][:main].play, id]
		end
	end

	def update
		@playing.each do |sample|
			# Garbage collection
			if !sample[0].playing?
				# Set the id in another variable so we can
				# access it after we delete sample.
				id = sample[1]
				@playing.delete sample

				# Continue loops
				if @samples[id][:loop] then play id end
			end
		end
	end
end

