class SRep 
  attr_accessor :index, :atoms, :skeletal_curve, :interpolated_spokes_begin, :interpolated_spokes_end, :extend_interpolated_spokes_end, :show_curve, :step_size, :color, :offset, :base_index, :mask_func
	
  def initialize(index, atoms, skeletal_curve, step_size, color, offset)
    @index = index
    @atoms = atoms
    @skeletal_curve = skeletal_curve
    @step_size = step_size
    @color = color
    @offset = offset
    @show_curve = true
    @interpolated_spokes_begin = []
    @interpolated_spokes_end = []
    @extend_interpolated_spokes_end = []
    @mask_func = []
    puts "srep fully initialized"
  end

  def initialize()
    @atoms = []
    @skeletal_curve = []
    @show_curve = true
    
    @interpolated_spokes_begin = []
    @interpolated_spokes_end = []
    @extend_interpolated_spokes_end = []
    @mask_func = [] 
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
              other_atom.corresponding_color = @color
           end
         end
      end
    end
  end

  def computingMask(all)
    @extend_interpolated_spokes_end.each_with_index do |e, i|
      
    end
  end

  def getExtendInterpolatedSpokesEnd()
    if @extend_interpolated_spokes_end.length != @interpolated_spokes_end.length
      @extend_interpolated_spokes_end = @interpolated_spokes_end.dup
    end
    return @extend_interpolated_spokes_end
  end

  def extendInterpolatedSpokes(ratio)
    if @extend_interpolated_spokes_end.length != @interpolated_spokes_end.length
      @extend_interpolated_spokes_end = @interpolated_spokes_end.dup
    end

    @interpolated_spokes_begin.each_with_index do |isb, ind|
      if @mask_func.length != @extend_interpolated_spokes_end.length
        @mask_func = []
        @extend_interpolated_spokes_end.length.times do 
          @mask_func << -1
        end
      end

      # if mask (func ind == -1) <-- have not intersected to anyone
      #extend spoke
      # calculate direction
      # here assume the stuff in @mask_func is ordered, later it may got modified to something like a map
      if @mask_func[ind] == -1
        spoke_v = [ @extend_interpolated_spokes_end[ind][0] - @interpolated_spokes_begin[ind][0], @extend_interpolated_spokes_end[ind][1] - @interpolated_spokes_begin[ind][1] ]
        extend_v = spoke_v.collect{|e| e * ratio }
        extend_v_end = [@interpolated_spokes_begin[ind][0] + extend_v[0], @interpolated_spokes_begin[ind][1] + extend_v[1] ]
        @extend_interpolated_spokes_end[ind] = extend_v_end
        # check intersection with others 
        
      end
    end
  end


end
