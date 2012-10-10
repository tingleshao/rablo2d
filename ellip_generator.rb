load'easyXMLBuilder.rb'
load 'pixel_factory.rb'

def genEllipsoid(im_size, ra, rb, bend,tapper)
	# generate a binary array would be ok, header file contains image size, XML format
	builder = EzXmlBuilder.new()
	builder.addNode('head', '')
	body = EzXmlNode.new("imdata", "123456789",1,1)
	body.addChildNode("color", "blue")
	builder.addNode(body)
	return builder
end


builder = genEllipsoid(1,1,1,1,1)
puts builder