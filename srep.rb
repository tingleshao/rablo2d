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

  def extendInterpolatedSpokes(ratio, sreps)
    # if the @extend_interpolated_spokes_end is not synchronzied with @interpolated_spokes_end, it means that it is the first time extension 
    # so deep copy the array @interpolated_spokes_end into @extend_interpolated_spokes_end
    if @extend_interpolated_spokes_end.length != @interpolated_spokes_end.length
      @extend_interpolated_spokes_end = @interpolated_spokes_end.dup
    end

    @extend_interpolated_spokes_end.each_with_index do |isb, ind|
      # if mask_func[ind] == -1) <-- have not intersected to anyone
      #extend spoke
      # calculate direction
      # here assume the stuff in @mask_func is ordered, later it may got modified to something like a map
      if isb[2] == -1
        spoke_v = [ @extend_interpolated_spokes_end[ind][0] - @interpolated_spokes_begin[ind][0], @extend_interpolated_spokes_end[ind][1] - @interpolated_spokes_begin[ind][1] ]
        extend_v = spoke_v.collect{|e| e * ratio }
        extend_v_end = [@interpolated_spokes_begin[ind][0] + extend_v[0], @interpolated_spokes_begin[ind][1] + extend_v[1], isb[2]]
        @extend_interpolated_spokes_end[ind] = extend_v_end
        # check intersection with others 
        sreps.each_with_index do |srep, srep_ind|   
          srep.extend_interpolated_spokes_end.each_with_index do |spoke_end, spoke_end_index|
          if (( srep.index != @index ) || ( (ind-spoke_end_index).abs > 1 ) && srep.index == @index  )
              check_result = checkSpokeIntersection(@interpolated_spokes_end[ind][0], @interpolated_spokes_end[ind][1], extend_v_end[0], extend_v_end[1], srep.interpolated_spokes_end[spoke_end_index][0], srep.interpolated_spokes_end[spoke_end_index][1], spoke_end[0], spoke_end[1])
              if check_result[0] 
                @extend_interpolated_spokes_end[ind][2] = srep.index
                if spoke_end[2] == -1
                  spoke_end[2] = @index
                end
              end
           
           end
          end
        end
      end
    end
  end


end
