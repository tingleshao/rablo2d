class SRep 
  attr_accessor :index, :atoms, :skeletal_curve, :step_size, :color, :offset, :base_index
	
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

  def checkIntersection(other_srep)
  # this method checks the intersection between self and another srep 
  # based on this intersection, decide the curve's linking index
    @atoms.each_with_index do |atom, i| 
       other_srep.atoms.each_with_index do |other_atom, j|
         
       end
    end
  end

  def computingMask(other_srep)
  end


end
