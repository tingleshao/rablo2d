 load 'easyXMLNode.rb'
 load 'easyXMLBuilder.rb'
 load 'pixel_factory.rb'
 
 class EllipFactory
	 @@size = 128
	attr_accessor :size, :rx, :ry, :centerX, :centerY, :bend, :tapper, :imageBuilder, :pixelFactory
	
	def initialize()
		@size = 128
		@rx = 20
		@ry = 15
		@centerX = 64
		@centerY = 64
		@bend = 0.4
		@tapper = 0.3
		@imageBuilder = EzXmlBuilder.new()
		@pixelFactory = PixelFactory.new()
	end
	
	def initialize(size, rx, ry, centerX, centerY, bend, tapper)
		@size = size
		@rx = rx
		@ry = ry
		@centerX = centerX
		@centerY = centerY
		@bend = bend
		@tapper = tapper
		@imageBuilder = EzXmlBuilder.new()
		@pixelFactory = PixelFactory.new()
	end
	
	def returnImage()
		header = EzXmlNode.new("header", "", 2, 0)
		header.addChildNode('imsize', @size.to_s)
		header.addChildNode('rx', @rx.to_s)
		header.addChildNode('ry', @ry.to_s)
		header.addChildNode('centerX', @centerX.to_s)
		header.addChildNode('centerY', @centerY.to_s)
		header.addChildNode('bend', @bend.to_s)
		header.addChildNode('tapper', @tapper.to_s)
		imageBuilder.addNode(header)
		# need to calculate the list of points on the boundary
		
	end
	
	def EllipFactory.calculatePointsOnBoundary(imsize, rx, ry, centerX, centerY)
		# firstly assume no bend nor tapper.......
		# we can genernate half of the points and use symmetry.
		# if tapper != 0, this won't work
		points = []
		ry = ry.to_f
		centerY = centerY.to_f
		for x in (centerX - rx)..centerX
			w = ((x - centerX).to_f / (rx).to_f)**2
			ww = 1.0 - w
			www =  Math.sqrt(ww * ry**2)
			puts "w " + w.to_s
 			y1 = centerY + www
			y2 = centerY - www
			points << [x,y1]
			points << [x,y2]
			points << [2 * centerX - x, y1]
			points << [2 * centerX - x, y2]
		end
		return points
	end
	
	def EllipFactory.deformEllip(points, bend, tapper)
		newPoints = []
		# need to center all the points to origin and make the range 0~1.
		xLst = points.collect { |p| p[0] } 
		yLst = points.collect { |p| p[1] }
		avgX = xLst.inject{ |sum, el| sum + el }.to_f / xLst.size
		avgY = yLst.inject{ |sum, el| sum + el }.to_f / yLst.size
		xLst = xLst.collect{ |ddl| ddl - avgX }
		yLst = yLst.collect{ |ddl| ddl - avgY}
		
		for i in 0..points.size - 1
			x = xLst[i].to_f/ @@size
			y = yLst[i] / @@size
			newX = x;
			newY = y * Math::exp(tapper * x) + bend * x**2
			newPoints << [(newX + avgX/@@size.to_f) * @@size, (newY + avgY/@@size.to_f) * @@size ]
		end
		return newPoints
	end
end