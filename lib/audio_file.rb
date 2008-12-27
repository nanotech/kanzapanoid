require 'easing'

class AudioFile
	attr_reader :sample, :loop, :intro, :begun

	def initialize(window, file, loop=false)
		@window = window

		@audio_folder = 'media/'
		@audio_format = '.ogg'

		main_file = @audio_folder + file + @audio_format

		@sample = Gosu::Sample.new(@window, main_file)
		@loop = loop
		@begun = false
		@instance = false
		@volume = Easer.new(1.0)
		@pan = Easer.new(0.0)
		@speed = Easer.new(1.0)

		if loop 
			# Look for an intro file for looped audio...
			intro_file = @audio_folder + file + '_intro' + @audio_format
			if File.exists? intro_file
				# ...and load it if it exists
				@intro = Gosu::Sample.new(@window, intro_file)
			end
		end

		@last_milli = milliseconds

		@fade_default = 1500
	end

	def play
		# If the sample has an intro, and hasn't been played before
		if !@begun and @intro
			# @begun is set when the intro has been played
			@begun = true

			# [0] is the actual sample, while [1] is it's id in @samples.
			@instance = @intro.play
		else
			@instance = @sample.play
		end
		
		@instance
	end

	def fade_to(target, time=@fade_default)
		@volume.to target, time
	end

	def fade_out(time=@fade_default); fade_to(0, time); end
	def fade_in(time=@fade_default); fade_to(1, time); end

	def pan_to(target, time=@fade_default)
		@pan.to target, time
	end

	def left(time=@fade_default); pan_to(-1, time); end
	def center(time=@fade_default); pan_to(0, time); end
	def right(time=@fade_default); pan_to(1, time); end

	def speed_to(target, time=@fade_default)
		@speed.to target, time
	end

	def reset(time=@fade_default)
		fade_to(1, time)
		pan_to(0, time)
		speed_to(1, time)
	end

	def update
		@volume.update
		@pan.update
		@speed.update

		@instance.volume = @volume.value
		@instance.pan = @pan.value
		@instance.speed = @speed.value
	end
end

