module CP
	YAML_TAG = 'chipmunk.slembcke.net,2008-12-08'

	class Vec2
		def to_yaml_type; '!'+YAML_TAG+'/cp-vec2'; end

		def to_yaml(opts = {})
			YAML::quick_emit(self, opts) do |out|
				out.map(taguri, to_yaml_style) do |map|
					map.add('x', self.x)
					map.add('y', self.y)
				end
			end
		end
	end

	class Body
		def to_yaml_type; '!'+YAML_TAG+'/cp-body'; end

		def to_yaml(opts = {})
			YAML::quick_emit(self, opts) do |out|
				out.map(taguri, to_yaml_style) do |map|
					map.add('a', self.a)
					map.add('f', self.f)
					map.add('i', self.i)
					map.add('m', self.m)
					map.add('p', self.p)
					map.add('rot', self.rot)
					map.add('t', self.t)
					map.add('v', self.v)
					map.add('w', self.w)
				end
			end
		end
	end

	module Shape
		def to_yaml_type; '!'+YAML_TAG+'/cp-shape'; end

		def to_yaml(opts={})
			YAML::quick_emit(self, opts) do |out|
				out.map(taguri, to_yaml_style) do |map|
					map.add('body', self.body)
					map.add('collision_type', self.collision_type)
					map.add('e', self.e)
					map.add('group', self.group)
					map.add('layers', self.layers)
					map.add('obj', self.obj)
					map.add('surface_v', self.surface_v)
					map.add('u', self.u)
				end
			end
		end

		def load(val)
			self.collision_type = val['collision_type']
			self.e = val['e']
			self.group = val['group']
			self.layers = val['layers']
			self.obj = val['obj']
			self.surface_v = val['surface_v']
			self.u = val['u']
		end

		class Circle
			attr_reader :radius, :offset

			def to_yaml_type; '!'+YAML_TAG+'/cp-shape-circle'; end
		end
	end

	YAML::add_domain_type(YAML_TAG, 'cp-vec2') do |type, val|
		Vec2.new(val['x'], val['y'])
	end

	YAML::add_domain_type(YAML_TAG, 'cp-body') do |type, val|
		body = Body.new(val['m'], val['i'])
		body.a = val['a']
		body.f = val['f']
		body.p = val['p']
		body.t = val['t']
		body.v = val['v']
		body.w = val['w']
		body
	end

	YAML::add_domain_type(YAML_TAG, 'cp-shape-circle') do |type, val|
		shape = CP::Shape::Circle.new(val['body'], 0, CP::Vec2.new(0,0))
		shape.load(val)
		shape
	end
end
