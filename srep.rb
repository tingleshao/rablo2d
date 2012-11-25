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
  # this method checks the intersection between self and another srep, for the BASE points
  # based on this intersection, decide the curve's linking index
    @atoms.each_with_index do |atom, i| 
       if atom.linking_index == -1
         other_srep.atoms.each_with_index do |other_atom, j|
           if Math.sqrt( (atom.x - other_atom.x)**2 + (atom.y - other_atom.y)**2 ) < (atom.expand_spoke_length[0] + other_atom.expand_spoke_length[0]) #=> intersection
              atom.linking_index = other_srep.index
              puts "intersect! "
             puts "other color: " + other_srep.color
              atom.corresponding_color = other_srep.color
              other_atom.linking_index = @index
           end
         end
      end
    end
  end

  def computingMask(other_srep)
    
  end


end
