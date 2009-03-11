#
# 2D vector class
#
class Vector
	attr_accessor :x, :y

	include Enumerable

	def initialize(x, y)
		@x = x
		@y = y
	end

	def join(other)
		x = yield @x, other.x
		y = yield @y, other.y
		Vector.new(x,y)
	end

	#def +(v); Vector.new(@x + v.x, @y + v.y) end
	def +(v); Vector.new(@x + v.x, @y + v.y) end
	def -(v); Vector.new(@x - v.x, @y - v.y) end
	def *(v); Vector.new(@x * v.x, @y * v.y) end
	def /(v); Vector.new(@x / v.x, @y / v.y) end

	def manhatten(v); (@x - v.x).abs + (@y - v.y).abs end
	def euclidean(v); Math.sqrt((@x - v.x)**2 + (@y - v.y)**2) end
	def diagonal(v); [(@x - v.x).abs, (@y - v.y).abs].max end

	# Like Float#to_i.
	def cutoff; map { |a| a.to_i } end
	def round; map { |a| a.round } end
	def reverse; Vector.new(@y, @x) end

	def [](index)
		case index
		when 0; @x
		when 1; @y
		end
	end

	# Enumerable stuff
	
	def each
		yield @x
		yield @y
	end

	def map
		Vector.new yield(@x), yield(@y)
	end

	# Comparable operators

	def <=>(other)
		if @x == other.x and @y == other.y
			0
		elsif @x < other.x or @y < other.y
			-1
		elsif @x > other.x or @y > other.y
			1
		end
	end

	def <(v); @x < v.x and @y < v.y end
	def >(v); @x > v.x and @y > v.y end
	def <=(v); @x <= v.x and @y <= v.y end
	def >=(v); @x >= v.x and @y >= v.y end
	def ==(v); compare(v, :==) end

	def compare(v, with)
		if v.is_a? Vector
			@x.send(with, v.x) and
			@y.send(with, v.y)
		end
	end

	# Converts a Vector to an Integer by adding x and y.
	def to_i; @x.to_i + @y.to_i end
	def to_s; "Vector(#{@x},#{@y})" end

	# Converts a Vector to an Array, setting
	# x and y to keys 0 and 1.
	def to_a; [@x, @y] end
	def to_vector; self end
end

# Shortcut for Vector.new
def Vector(*args); Vector.new(*args) end

# Vector-related helper methods.
class Array
	def to_vector
		Vector.new(self.x, self.y)
	end

	def x; self.at(0) end
	def y; self.at(1) end
	def z; self.at(2) end

	def x=(v); self[0] = v end
	def y=(v); self[1] = v end
	def z=(v); self[2] = v end
end

class Numeric
	# Convert a number to a vector by setting both
	# x and y to the number.
	def to_vector; Vector(self, self) end
	def x; self end
	def y; self end
end
