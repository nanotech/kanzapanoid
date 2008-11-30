class Fader
	attr_accessor :value, :target, :time, :elapsed

	def initialize(value=0.0)
		@value = value
		@target = @value
		@time = 0.0
		@elapsed = 0.0
	end

	def to(target, time)
		@target = target
		@time = time
		@elapsed = 0.0
	end

	def update
		if @target != @value
			@value -= (@value - @target) / (@time - @elapsed)
			@elapsed += 1
		end
	end
end

