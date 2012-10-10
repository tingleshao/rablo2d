# first make it run
# window

#~ require 'rubyvis'
load 'ellip_factory.rb'
load 'image_toolbox.rb'


def point(x, y, color, bg_color, app)
	app.stroke color
	app.line x, y, x, y+1
	app.stroke bg_color
	app.line x, y+1, x+1, y+1
end

class Field
  CELL_SIZE = 20
  COLORS = %w(#00A #0A0 #A00 #004 #040 #400 #000)
  	
  #~ newP = EllipFactory.deformEllip(p, 1.2, 0.0)
  #~ p = newP
	
  class Cell
    attr_accessor :flag
    def initialize(aflag = false)
      @flag = aflag
    end
  end
  
  class Bomb < Cell
    attr_accessor :exploded
    def initialize(exploded = false)
      @exploded = exploded
    end
  end
  
  class OpenCell < Cell
    attr_accessor :number
    def initialize(bombs_around = 0)
      @number = bombs_around
    end
  end
  
  class EmptyCell < Cell; end
  
  attr_reader :cell_size, :offset
  
  def initialize(app, points)
    @app = app
    @field = []
    @width, @height= 800, 600
    @offset = [(@app.width - @width.to_i) / 2, (@app.height - @height.to_i) / 2]
    @fullpoints = points
  end
  
  def setPoints(points)
	  @fullpoints = points
  end
  #~ def total_time
    #~ @latest_time = Time.now - @start_time unless game_over? || all_found?
    #~ @latest_time
  #~ end
  
  #~ def click!(x, y)
    #~ return unless cell_exists?(x, y)
    #~ return if has_flag?(x, y)
    #~ return die!(x, y) if bomb?(x, y)
    #~ open(x, y)
    #~ discover(x, y) if bombs_around(x, y) == 0
  #~ end  

  #~ def flag!(x, y)
    #~ return unless cell_exists?(x, y)
    #~ self[x, y].flag = !self[x, y].flag unless self[x, y].is_a?(OpenCell)
  #~ end  
  
  #~ def game_over?
    #~ @game_over 
  #~ end
  
  def render_cell(x, y, color = "#AAA", stroke = true)
    @app.stroke "#666" if stroke
    @app.fill color
    @app.rect x*cell_size, y*cell_size, cell_size-1, cell_size-1
    @app.stroke "#BBB" if stroke
    @app.line x*cell_size+1, y*cell_size+1, x*cell_size+cell_size-1, y*cell_size
    @app.line x*cell_size+1, y*cell_size+1, x*cell_size, y*cell_size+cell_size-1
  end
  
  def render_flag(x, y)
    @app.stroke "#000"
    @app.line(x*cell_size+cell_size / 4 + 1, y*cell_size + cell_size / 5, x*cell_size+cell_size / 4 + 1, y*cell_size+cell_size / 5 * 4)
    @app.fill "#A00"
    @app.rect(x*cell_size+cell_size / 4+2, y*cell_size + cell_size / 5, 
      cell_size / 3, cell_size / 4)
  end

  
  def render_number(x, y)
    render_cell(x, y, "#999", false)
    if self[x, y].number != 0 then
      @app.nostroke
      @app.para self[x, y].number.to_s, :left => x*cell_size + 3, :top => y*cell_size - 2, 
        :font => '13px', :stroke => COLORS[self[x, y].number - 1]
    end
  end
  
  def render_point_big(x, y, color)
	@app.stroke color
	@app.strokewidth 5
#	@app.fill "#333"
	@app.oval x,y, 5
  end

  def render_figure(points, cx,cy, color, is_big, scale)
	if is_big
		points.each do |point|
			render_point_big(scale* (point[0] + cx), scale * (point[1] + cy), color)
		end
	end
  end

  def paint
	@app.nostroke
	render_figure(@fullpoints, 200, 200, "#66CCFF", true, 2)
	#render
  end  

  def bombs_left
    @bombs - @field.flatten.compact.reject {|e| !e.flag }.size
  end  

  def all_found?
    @field.flatten.compact.reject {|e| !e.is_a?(OpenCell) }.size + @bombs == @w*@h
  end  

  def reveal!(x, y)
    return unless cell_exists?(x, y)
    return unless self[x, y].is_a?(Field::OpenCell)
    if flags_around(x, y) >= self[x, y].number then
      (-1..1).each do |v|
        (-1..1).each { |h| click!(x+h, y+v) unless (v==0 && h==0) or has_flag?(x+h, y+v) }
      end
    end      
  end  
  
  private 
  
  def cell_exists?(x, y)
    ((0...@w).include? x) && ((0...@h).include? y)
  end
  
  def has_flag?(x, y)
    return false unless cell_exists?(x, y)
    return self[x, y].flag
  end
  
  def bomb?(x, y)
    cell_exists?(x, y) && (self[x, y].is_a? Bomb)
  end
  
  def can_be_discovered?(x, y)
    return false unless cell_exists?(x, y)
    return false if self[x, y].flag
    cell_exists?(x, y) && (self[x, y].is_a? EmptyCell) && !bomb?(x, y) && (bombs_around(x, y) == 0)
  end  
  
  def open(x, y)
    self[x, y] = OpenCell.new(bombs_around(x, y)) unless (self[x, y].is_a? OpenCell) or has_flag?(x, y)
  end
  
  def neighbors
    (-1..1).each do |col|
      (-1..1).each { |row| yield row, col unless col==0 && row == 0 }
    end  
  end
  
  def discover(x, y)
    open(x, y)
    neighbors do |col, row|
      cx, cy = x+row, y+col
      next unless cell_exists?(cx, cy)
      discover(cx, cy) if can_be_discovered?(cx, cy)
      open(cx, cy)
    end
  end  


  def [](*args)
    x, y = args
    raise "Cell #{x}:#{y} does not exists!" unless cell_exists?(x, y)
    @field[y][x]
  end
  
  def []=(*args)
    x, y, v = args
    cell_exists?(x, y) ? @field[y][x] = v : false
  end
end


Shoes.app :width => 1000, :height => 800, :title => '2d multi object' do
 def render_field
    clear do
      background rgb(50, 50, 90, 0.7)
      flow :margin => 4 do
        button("Dilate") { 
		@points = dilatePointList(@points,128,5,true)
		@field.setPoints( @points )
		@field.paint }
	button("Reset") {
		@binpoints = generateBinary(128,20,15,64,64,0.0,0.0)
		@points= binaryToPointList(@binpoints, 128)
		new_game @points
	}
       end
     stack do @status = para :stroke => black end
     @field.paint
     end  
end
  
  def new_game points 
    @field = Field.new self, points
    render_field
  end
  
  @binpoints = generateBinary(128,20,15,64,64,0.0,0.0)
  @points= binaryToPointList(@binpoints, 128)
  new_game @points 
 
end
