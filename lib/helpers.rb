# Various methods that make various stuff easier.

class Numeric
	# Convenience method for converting from radians to a Vec2 vector.
	def radians_to_vec2; CP::Vec2.new(Math::cos(self), Math::sin(self)); end

	# Same as above, but converts to a plain Ruby array.
	def radians_to_cartesian; [Math::cos(self), Math::sin(self)]; end

	def radians_to_gosu; self.radians_to_degrees + 90; end;
	def gosu_to_radians; (self - 90).radians_to_degrees; end;

	def radians_to_degrees; self * (180.0 / Math::PI); end;
	def degrees_to_radians; self / (180.0 / Math::PI); end;

	def distance_to(other); Math::sqrt(self**2 + other**2); end
end

class String
	# This converts a space separated string into a Chipmunk vector
	def to_vec2
		vertex = self.split
		CP::Vec2.new(vertex[0].to_f, vertex[1].to_f)
	end
end

require 'chipmunk_object.rb'
