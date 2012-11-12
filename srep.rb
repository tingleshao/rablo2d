class SRep 
	attr_accessor :atoms, :skeletal_curve, :step_size 
	
	def initialize(atoms, skeletal_curve, step_size)
		@atoms = atoms
		@skeletal_curve = skeletal_curve
		@step_size = step_size
	end
	
	

	def to_s
		"i am an s-rep!"
	end
	
	

end
