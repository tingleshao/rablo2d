class Atom
  attr_accessor :spoke_length, :spoke_direction, :type, :x, :y, :correspondingColor
	
  def initialize(spoke_length, spoke_direction, type, x, y, cc)
    @spoke_length = spoke_length
    @spoke_direction = spoke_direction
    @type = type
    @x = x
    @y = y
    @correspondingColor = cc
  end
	
  def to_s 
    "i am an atom! \n my type: " + @type + "\n my position: x: " + @x.to_s + " y: " + @y.to_s + "\n my spokes length: " + @spoke_length.to_s + "\n my spoke direction: " + @spoke_direction.to_s + "\n my correspoinding color: " + @correspondingColor.to_s
  end

  def dilate(ratio)
    @spoke_length[0] = @spoke_length[0] * ratio
    @spoke_length[1] = @spoke_length[1] * ratio
    if @type == 'end'
      @spoke_length[2] = @spoke_length[2] * ratio
    end
  end

end
