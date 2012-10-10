load 'easyXMLNode.rb'

class PixelFactory
	def initialize()
	end
	
	def returnPixel(*args)
		point = EzXmlNode.new("point", "", 2, 0) 
		if (args.size == 3)
			point.addChildNode('x', x.to_s)
			point.addChildNode('y', y.to_s)
			point.addChildNode('z', z.to_s)
			return point
		elsif (args.size == 2)
			point.addChildNode('x', x.to_s)
			point.addChildNode('y', y.to_s)
		end
	end
end

