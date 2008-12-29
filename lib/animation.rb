class Animation
	attr_accessor :motions

	def initialize
		@motions = {}
		@start = milliseconds
	end

	def update
		@motions.each do |name, motion|
			if motion[:range] and (motion[:easer].time >= motion[:easer].duration)

				duration = motion[:duration] || @motions[:defaults][:duration]

				if motion[:inverse] and motion[:easer].value == 0
					if motion[:inverse_alternate]
						motion[:easer].to motion[:range].last, duration
					else
						motion[:easer].to motion[:range].first, duration
					end
				else
					range = motion[:range]

					if motion[:easer].change > (range.first + range.last) / 2
						motion[:easer].to range.first, duration
					else
						motion[:easer].to range.last, duration
					end
				end
			end

			motion[:easer].update
		end
	end
end

module Animator
	def animate(*motions, &block)
		m = @animation.motions
		if block
			motions.each do |motion|
				@animation_scope = motion
				m[motion] = {}

				yield

				easing_direction = m[motion][:easing_direction] || m[:defaults][:easing_direction]
				easing_method = m[motion][:easing_method] || m[:defaults][:easing_method]

				m[motion][:easer] = Easer.new 0.0, easing_direction, easing_method

				if !m[motion][:inverse_every] and motions.index(motion) == 0 and motions.size == 2
					m[motion][:inverse] = nil
				end

				@animation_scope = nil
			end
		else
			motion = motions.first
		end

		m[motion] ? m[motion][:easer].value : 0
	end

	def easing(direction, method=nil)
		unless method
			method = direction 
			direction = :in_out
		end

		@animation.motions[@animation_scope][:easing_method] = method
		@animation.motions[@animation_scope][:easing_direction] = direction
	end

	def range(value)
		@animation.motions[@animation_scope][:range] = [value.first.to_f, value.last.to_f]
	end

	def duration(value)
		@animation.motions[@animation_scope][:duration] = value
	end

	def inverse(*opts)
		m = @animation.motions
		m[@animation_scope][:inverse] = true
		m[@animation_scope][:inverse_alternate] = true if opts.include? :alternate
		m[@animation_scope][:inverse_every] = true if opts.include? :every
	end
end
