class Atom
  attr_accessor :spoke_length, :expand_spoke_length, :spoke_direction, :type, :x, :y, :corresponding_color, :linking_index
	
  def initialize(spoke_length, spoke_direction, type, x, y, cc)
    @spoke_length = spoke_length
    @expand_spoke_length = spoke_length
    @spoke_direction = spoke_direction
    @type = type
    @x = x
    @y = y
    @corresponding_color = cc
    @linking_index = -1
  end
	
  def to_s 
    "i am an atom! \n my type: " + @type + "\n my position: x: " + @x.to_s + " y: " + @y.to_s + "\n my spokes length: " + @spoke_length.to_s + "\n my spoke direction: " + @spoke_direction.to_s + "\n my correspoinding color: " + @corresponding_color.to_s
  end

  def dilate(ratio)
    if @linking_index == -1
      @expand_spoke_length[0] = @expand_spoke_length[0] * ratio
      @expand_spoke_length[1] = @expand_spoke_length[1] * ratio
      if @type == 'end'
        @expand_spoke_length[2] = @expand_spoke_length[2] * ratio
      end
    end
  end

end
