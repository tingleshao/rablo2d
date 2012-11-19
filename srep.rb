class SRep 
  attr_accessor :index, :atoms, :skeletal_curve, :step_size, :color, :offset
	
  def initialize(index, atoms, skeletal_curve, step_size, color, offset)
    @index = index
    @atoms = atoms
    @skeletal_curve = skeletal_curve
    @step_size = step_size
    @color = color
    @offset = offset
    puts "srep fully initialized"
  end

  def initialize()
    @atoms = []
    @skeletal_curve = []
    puts "null srep initialized"
  end

  def to_s
    "i am an s-rep! \n"
    "Here are my atoms: \n"
    @atoms.each do |at|
       puts at
    end
  end

  def getLength
    if @skeletal_curve == []
       return @atoms.size
    else 
       return @skeletal_curve.size
    end
  end

  def rotate
  # this method would rotate the srep.
  end

end
