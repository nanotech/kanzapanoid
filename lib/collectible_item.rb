# A simple extension of Item that provides the ability
# to be collected by another object on collision.
#
class CollectibleItem < Item
	def collided_with(other)
		other.collect self #if other.respond_to?(:collect)
	end
end
