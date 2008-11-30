require 'audio_file'

class Audio
	attr_reader :samples, :playing

	def initialize(window, file=false)
		@window = window

		@samples = [] # all loaded samples
		@playing = [] # currently playing samples

		# If Audio.new was passed a file, load and loop it.
		# Since this is the first loaded file, it's id is 0.
		if file then load file, true; play 0 end
	end

	def load(file, loop=false)
		@samples.push AudioFile.new(@window, file, loop)

		# Return the sample's id
		@samples.size - 1
	end

	def play(id)
		@playing.push [@samples[id].play, id]
	end

	def update
		@playing.each do |sample|
			# Set the id in another variable so we can
			# access it even after we delete sample.
			id = sample[1]

			# Garbage collection
			if !sample[0].playing?
				@playing.delete sample

				# Continue loops
				if @samples[id].loop then play id end
			end

			@samples[id].update
		end
	end
end

