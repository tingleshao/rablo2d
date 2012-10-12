load 'ellip_factory.rb'
load 'image_toolbox.rb'
load 'srep_toolbox.rb'

def point(x, y, color, bg_color, app)
	app.stroke color
	app.line x, y, x, y+1
	app.stroke bg_color
	app.line x, y+1, x+1, y+1
end

class Field

  attr_reader @srep, @shift
  
  def initialize(app, points, srep, shift)
    @app = app
    @field = []
    @width, @height= 800, 600
    @offset = [(@app.width - @width.to_i) / 2, (@app.height - @height.to_i) / 2]
    @fullpoints = points
    @srep = [ srep ] 
    @shift = [ shift ]
  end
  
  def setPoints(points)
	  @fullpoints = points
  end
  
  def setSrep(srep, index) 
	  @srep[index] = srep
  end
  
  def addSrep(srep)
	  @srep << srep
  end
  
  def render_point_big(x, y, color)
	@app.stroke color
	@app.strokewidth 2
	@app.nofill
	@app.oval x-1,y-1, 2
  end

  def render_figure(points, shiftx, shifty, color, is_big, scale)
	if is_big
		points.each_slice(4) do |point|
			render_point_big(scale* (point[0][0] + shiftx), scale * (point[0][1] + shifty), color)
		end
	end
  end
  
  def render_circle(cx, cy, r, color)
       @app.stroke color
       @app.nofill 
       @app.oval cx,cy, r
  end


  def render_srep(srep, shiftx, shifty, color, scale, show_sphere)
	srep.each do |a|
		render_point_big(a[0][0]+shiftx, a[0][1]+shifty , color)
		if show_sphere
			render_circle(a[0][0]+shiftx-a[2][0].abs/Math.sqrt(2),  a[0][1]+shifty-a[2][0].abs/Math.sqrt(2), Math.sqrt(2)*a[2][0].abs, color)
			#alert a[2][0]
		end
	end
  end 
  
  def paint
	@app.nostroke
	 render_srep(@srep, 200 + @shift, 200 + @shift, "#66CCFF", 1.5, true )
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
		@srep.each do |a|
			if a[2][0] < 0 then a[2][0] = a[2][0] - 2 else a[2][0] = a[2][0] + 2 end
		end
		refresh @points, @srep, @shift
		@field.paint
		}
	button("Reset") {
		@binpoints = generateBinary(128,20,15,64,64,0.0,0.0)
		@points= binaryToPointList(@binpoints, 128)
		@srep = generate2DDiscreteSrep(20,15,64,64,128)
		refresh @points, @srep, @shift
	}
	button("Translate") {
		#~ @srep.each do |a|
			#~ if a[0][0] < 0 then a[0][0] = a[0][0] - 5 else a[0][0] = a[0][0] + 5 end
		#~ end
		@shift = @shift + 5
		refresh @points, @srep, @shift
		@field.paint
	}
	button("Rotate") {
		rotateSrep(@srep, Math::PI/6)
		refresh @points, @srep, @shift
		@field.paint
	}
	end
     stack do @status = para :stroke => black end
     @field.paint
     end  
end
  
  def refresh points, srep, shift
    self.nofill
    @field = Field.new self, points, srep, shift
    render_field
  end
  @binpoints = generateBinary(128,20,15,64,64,0.0,0.0)
  #~ @points= binaryToPointList(@binpoints, 128)
  @shift = 0
  @srep = generate2DDiscreteSrep(20,15,64,64,128)
  refresh @points, @srep, @shift
 
end
