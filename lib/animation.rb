require 'easing'

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

	def group=(name)
		if name != @group
			@motions.each_value { |m| m.reset }
			@group = name
		end
	end
end

class Motion
	attr_accessor :groups, :easer, :first_run
	attr_reader :animator

	def initialize(animator)
		@animator = animator
		@groups = { @animator.group => Group.new(self) }
		@easer = Easer.new 0.0, :in_out, :quad, :manual
		@easer.duration = @animator.defaults.easer.duration if @animator.defaults
		@direction = true
		reset
	end

	def group
		@groups[@animator.group] ||= Group.new(self)
	end

	def range=(range)
		group.range = [range.first.to_f, range.last.to_f]
	end

	def reset
		@first_run = true
	end

	def update
		group = @groups[@animator.group]

		if group and (@easer.time >= @easer.duration)

			if @first_run
				@direction = group.inverse
				@first_run = false
			end

			if @direction
				@easer.to group.range.first
			else
				@easer.to group.range.last
			end

			# Reverse direction
			@direction = !@direction
		end

		#             v Temporary animation de-sync fix
		@easer.update 20 #milliseconds - $last_time
	end

	def method_missing(method, *args)
		group.send(method, *args)
	end

	class Group
		attr_accessor :range, :inverse

		def initialize(motion)
			@animator = motion.animator
			@motion = motion
			@range = [0,0]
			@inverse = false
		end
	end
end

module AnimatorAPI
	def animate(*motions)
		m = @animator.motions

		motions.each_with_index do |motion_name, id|
			@animation_scope = motion_name
			m[motion_name] = Motion.new(@animator) unless m[motion_name]
			motion = m[motion_name]

			yield

			motion.easer.direction ||= m[:defaults].easer.direction
			motion.easer.method ||= m[:defaults].easer.method
			motion.inverse = !(motion.inverse and motions.size == 2 and id == 0)

			@animation_scope = nil
		end
	end

	def animation(*names)
		names.each do |name|
			@animator.group = name
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
		current_motion.range = value
	end

	def duration(value)
		current_motion.easer.duration = value
	end

	def inverse(value=true)
		current_motion.inverse = value
	end

	def current_motion
		@animator.motions[@animation_scope] || @animator.defaults
	end
end
