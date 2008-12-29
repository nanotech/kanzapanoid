class Animator
	attr_accessor :motions, :groups, :group, :defaults

	def initialize
		@group = :main
		@motions = {}
		@start = milliseconds
		@defaults = Motion.new self
	end

	def render(motion)
		@motions[motion] ? @motions[motion].easer.value : 0
	end

	def update
		@motions.each_value { |m| m.update }
	end
end

class Motion
	attr_accessor :ranges, :easer, :inverse, :group

	def initialize(animator)
		@animator = animator
		@ranges = { @animator.group => 0..0 }
		@inverse = { :do => false }
		@easer = Easer.new 0.0, :in_out, :quad, :manual
		@easer.duration = @animator.defaults.easer.duration if @animator.defaults
		@first_run = true
	end

	def update
		group = @animator.group

		if @ranges[group] and (@easer.time >= @easer.duration)

			range = @ranges[group]

			if @inverse[:do] and @first_run
				if @inverse[:alternate]
					@easer.to range.first
				else
					@easer.to range.last
				end
			else
				if @easer.change > (range.first + range.last) / 2
					@easer.to range.first
				else
					@easer.to range.last
				end
			end

			@first_run = false
		end

		#             v Temporary animation de-sync fix
		@easer.update 20 #milliseconds - $last_time
	end
end

module AnimatorAPI
	def animate(*motions)
		m = @animation.motions

		motions.each do |motion|
			@animation_scope = motion
			m[motion] = Motion.new(@animation) unless m[motion]

			yield

			m[motion].easer.direction = m[motion].easer.direction || m[:defaults].easer.direction
			m[motion].easer.method = m[motion].easer.method || m[:defaults].easer.method

			if !m[motion].inverse[:every] and motions.size == 2
				index = motions.index(motion)
				alternate = m[motion].inverse[:alternate]

				if alternate and index == 1
					m[motion].inverse.delete(:alternate)
				elsif !alternate and index == 0
					m[motion].inverse[:do] = false
				end
			end

			@animation_scope = nil
		end
	end

	def animation(*names)
		names.each do |name|
			@animation.group = name
			yield
		end
	end

	def easing(direction, method=nil)
		unless method
			method = direction 
			direction = :in_out
		end

		m = current_motion
		m.easer.method = method
		m.easer.direction = direction
	end

	def range(value)
		current_motion.ranges[@animation.group] = [value.first.to_f, value.last.to_f]
	end

	def duration(value)
		current_motion.easer.duration = value
	end

	def inverse(*opts)
		m = current_motion
		m.inverse[:do] = true
		m.inverse[:alternate] = true if opts.include? :alternate
		m.inverse[:every] = true if opts.include? :every
	end

	def current_motion
		m = @animation.motions[@animation_scope]
		m = @animation.defaults unless m
		m
	end
end
