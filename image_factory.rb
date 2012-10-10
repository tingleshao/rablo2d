 load 'easyXMLNode.rb'
 load 'pixel_factory.rb'
 
 class ImageFactory
	attr_accessor :size, :rx, :ry, :rz, :bend, :tapper
	
	def initialize()
		@size = 128
		@rx = 20
		@ry = 15
		@rz = 10
		@bend = 0.4
		@tapper = 0.3
	end
	
	def initialize(size, rx, ry, rz, bend, tapper)
		@size = size
		@rx = rx
		@ry = ry
		@rz = rz
		@bend = bend
		@tapper = tapper
	end
	
	def returnImage()
		
	end
end