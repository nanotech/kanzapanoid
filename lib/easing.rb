class Numeric

	# Original easing equations by [Robert Penner] [1].
	# Licenced under the [BSD licence] [2].
	#
	# [1] http://www.robertpenner.com/easing/
	# [2] http://www.opensource.org/licenses/bsd-license.php
	def ease(direction, method, t, d, c)
		b = self.to_f
		t = t.to_f
		d = d.to_f
		c = c.to_f

		case method
		when :quad
			case direction
			when :in then c*(t/=d)*t + b
			when :out then -c * (t/=d)*(t-2) + b
			when :in_out
				return c/2*t*t + b if (t/=d/2) < 1
				-c/2 * ((t-=1)*(t-2) - 1) + b
			end
		when :cubic
			case direction
			when :in then c * (t/d)**3 + b
			when :out then c * ((t/d-1)**3 + 1) + b
			when :in_out
				return c/2 * (t**3) + b if (t/=d/2) < 1
				c/2 * ((t-2)**3 + 2) + b
			end
		when :quart
			case direction
			when :in then c * (t/d)**4 + b
			when :out then -c * ((t/d-1)**4 - 1) + b
			when :in_out
				return c/2 * t**4 + b if (t/=d/2) < 1
				-c/2 * ((t-2)**4 - 2) + b
			end
		when :quint
			case direction
			when :in then c * (t/d)**5 + b
			when :out then c * ((t/d-1)**5 + 1) + b
			when :in_out
				return c/2 * t**5 + b if (t/=d/2) < 1
				c/2 * ((t-2)**5 + 2) + b
			end
		when :sine
			case direction
			when :in then c * (1 - Math.cos(t/d * (Math::PI/2))) + b
			when :out then c * Math.sin(t/d * (Math::PI/2)) + b
			when :in_out then c/2 * (1 - Math.cos(Math::PI*t/d)) + b
			end
		when :expo
			case direction
			when :in then c * 2**(10 * (t/d - 1)) + b
			when :out then c * (-(2**(-10 * t/d)) + 1) + b
			when :in_out
				return c/2 * 2**(10 * (t - 1)) + b if (t/=d/2) < 1
				c/2 * (-(2**(-10 * t-=1)) + 2) + b
			end
		when :circ
			case direction
			when :in then c * (1 - Math.sqrt(1 - (t/=d)*t)) + b
			when :out then c * Math.sqrt(1 - (t=t/d-1)*t) + b
			when :in_out
				return c/2 * (1 - Math.sqrt(1 - t*t)) + b if (t/=d/2) < 1
				c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b
			end
		when :elastic
			s = 1.70158
			p = 0.0
			a = c
			return b if t.zero?

			case direction
			when :in, :out
				return b + c if (t/=d) == 1
				p = d * 0.3 if p.zero?
			when :in_out then
				return b + c if (t/=d / 2) == 2
				p = d * (0.3*1.5) if p.zero?
			end

			if a < c.abs
				a = c
				s = p / 4.0
			else
				s = p/(2*Math::PI) * Math.asin(c/a)
			end

			case direction
			when :in
				-(a*(2**(10*(t-=1))) * Math.sin((t*d-s)*(2*Math::PI)/p)) + b

			when :out
				a*(2**(-10*t)) * Math.sin( (t*d-s)*(2*Math::PI)/p ) + c + b

			when :in_out
				return -0.5*(a*(2**(10*(t-=1))) * Math.sin( (t*d-s)*(2*Math::PI)/p )) + b if t < 1
				a*(2**(-10*(t-=1))) * Math.sin( (t*d-s)*(2*Math::PI)/p )*0.5 + c + b
			end

		when :back
			s = 1.70158 unless s

			case direction
			when :in
				c*(t/=d)*t*((s+1)*t - s) + b
			when :out
				c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b
			when :in_out
				return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b if (t/=d/2) < 1
				c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b
			end

		when :bounce
			case direction
			when :in
				c - 0.ease(:out, :bounce, d-t, d, c) + b
			when :out
				if (t/=d) < 1/2.75
					return c*(7.5625*t*t) + b
				elsif t < 2/2.75
					return c*(7.5625*(t-=(1.5/2.75))*t + 0.75) + b
				elsif t < 2.5/2.75
					return c*(7.5625*(t-=(2.25/2.75))*t + 0.9375) + b
				else
					return c*(7.5625*(t-=(2.625/2.75))*t + 0.984375) + b
				end
			when :in_out
				return 0.ease(:in, :bounce, t*2, d, c) * 0.5 + b if t < d/2
				0.ease(:out, :bounce, t*2-d, d, c) * 0.5 + c*0.5 + b
			end
		else
			# Default to linear easing
			c*t/d + b
		end
	end
end

class Easer
	attr_accessor :value, :change, :time, :duration, :direction, :method

	def initialize(value=0.0, direction=:none, method=:linear, manual_time=false)
		@value = value.to_f
		@direction = direction
		@method = method
		@manual_time = manual_time
		self.to(value, 0)
	end

	def to(target, duration=@duration)
		@change = target.to_f - @value
		@beginning = @value
		@duration = duration.to_f
		@start = (@manual_time) ? 0 : milliseconds
		@time = 0
	end

	def update(time_change=0)
		if @time < @duration
			@time = milliseconds - @start unless @manual_time
			@time += time_change
			@time = @duration if @time > @duration
			@value = @beginning.ease(@direction, @method,
									 @time, @duration, @change)
		end
	end

	def to_f; @value.to_f; end
	def to_i; @value.to_i; end
	def to_s; @value.to_s; end
end

class VectorEaser
	def initialize(vect, *args)
		@easers = []

		vect.each do |scalar|
			@easers << Easer.new(scalar, *args)
		end
	end

	def update
		@easers.each { |e| e.update }
	end

	def to(value, *args)
		@easers.each_with_index do |e,s|
			e.to(value[s], *args)
		end
	end

	def target; get :target end
	def value; get :value end

	def get(value)
		values = []

		@easers.each do |e|
			values << e.send(value)
		end

		values.to_vector
	end
end
