class Atom
	attr_accessor :spoke_length, :spoke_direction, :type, :positions
	
	def initialize(spoke_length, spoke_direction, type,  positions)
		@spoke_length = spoke_length
		@spoke_direction = spoke_direction
		@type = type
		@positions = positions
	end
	
	def to_s 
		"i am an atom!"
	end
end
