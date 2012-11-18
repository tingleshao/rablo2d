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

  attr_reader :sreps, :shifts, :totalCorreLst
  
  def initialize(app, points, sreps, shifts)
    @app = app
    @field = []

    @width, @height= 800, 600

    @offset = [(@app.width - @width.to_i) / 2, (@app.height - @height.to_i) / 2]
    @fullpoints = points
    @sreps = sreps 
    @shifts = shifts
    @colorLst = ["#66CCFF"]
    (@sreps.length-1).times do |i|
      color = ("66CCFF"[0..1].to_i(16) + (i + 1) *  20).to_s(16) + ("66CCFF"[2..3].to_i(16) - (i+1)*20).to_s(16) + ("66CCFF"[4..5].to_i(16) - (i + 1) * 50).to_s(16)
      color = "#" + color.to_s
      @colorLst << color
    end
    @totalCorreLst = []
  end
  
  def setPoints(points)
    @fullpoints = points
  end
  
  def setSrep(srep, index) 
    @sreps[index] = srep
  end
  
  def addSrep(srep) 
    @sreps << srep
  end
  
  def setShift(shift, index)
    @shifts[index] = shift
  end

  def addShift(shift)
    @shifts << shift
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
  
  def render_circle(cx, cy, d, color)
    @app.stroke color
    @app.nofill 
    @app.oval cx, cy, d
  end

  def render_spokes(cx, cy, type, spoke_length, spoke_direction, color)
    @app.stroke color
    if type == 'end'
       @app.line(cx, cy, cx + spoke_length[0] * spoke_direction[0][0], cy - spoke_length[0] * spoke_direction[0][1])
       @app.line(cx, cy, cx + spoke_length[1] * spoke_direction[1][0], cy - spoke_length[1] * spoke_direction[1][1])
       @app.line(cx, cy, cx + spoke_length[2] * spoke_direction[2][0], cy - spoke_length[2] * spoke_direction[2][1])
       puts "middle y direction: " + spoke_direction[2][1].to_s 
    elsif type == 'inner'
       @app.line(cx, cy, cx + spoke_length[0] * spoke_direction[0][0], cy - spoke_length[0] * spoke_direction[0][1])
       @app.line(cx, cy, cx + spoke_length[1] * spoke_direction[1][0], cy - spoke_length[1] * spoke_direction[1][1])
    end
  end

  def render_srep(*args)
    srep = args[0]
    shiftx  = args[1]
    shifty = args[2]
    scale = args[4]
    show_sphere = args[5]
    if args.length == 7
      totalCorreLst = args[6]
    end
	  
    srep.atoms.each_with_index do |atom|
      if totalCorreLst != nil
	render_atom(atom.x + shiftx, atom.y + shifty, atom.correspondingColor)
      else 
	render_atom(atom.x + shiftx, atom.y + shifty, srep.color)
      end
      if show_sphere
	render_circle(atom.x + shiftx - atom.spoke_length[0], atom.y + shifty - atom.spoke_length[0], atom.spoke_length[0] * 2 , srep.color)
      end
      render_spokes(atom.x+shiftx, atom.y+shifty, atom.type, atom.spoke_length, atom.spoke_direction, srep.color)
    end
  end 
  
  def render_atom(x, y, color)
    render_point_big(x, y, color)
  end
  
  def paint
    @app.nostroke
    @totalCorreLst = checkRefSrepIntersection

    @sreps.each.with_index do |srep, i|
      if i == 0 #=> reference obj
	render_srep(srep, 200 + @shifts[i] , 200 + @shifts[i] , @colorLst[i], 1.5, true, @totalCorreLst)
      else
	render_srep(srep, 200 + @shifts[i] , 200 + @shifts[i] , @colorLst[i], 1.5, true ) 
      end
    end
  end  
 
  def checkRefSrepIntersection
    refsrep = @sreps[0] 
      totalCorreLst = []
      @sreps[0].getLength.times do 
	totalCorreLst << [0, nil]
      end
      (1..@sreps.length-1).each do |i|
        correLst = checkSrepIntersection(refsrep, @sreps[i], @shifts[0], @shifts[i])
	totalCorreLst = combineCorrespondenceListResults(totalCorreLst, correLst, i)
      end
      return totalCorreLst
  end
 
 def combineCorrespondenceListResults(rcdLst, srepCorLst, srepIndex)
   newRcdLst = []
   rcdLst.length.times do |i|
     newRcdLst << [rcdLst[i][0], rcdLst[i][1]]
   end
   srepCorLst.each.with_index do |ele, i|
     if ele[0] == 1
       newRcdLst[i] = [srepIndex, ele[1]] 
     end
   end
   return newRcdLst
 end

 def getHowManyColored()
   count = 0
   @totalCorreLst.each do |e|
     if e[1] != nil
       count = count +1
     end
   end
   return count
 end

 def [](*args)
    x, y = args
    raise "Cell #{x}:#{y} does not exist!" unless cell_exists?(x, y)
    @field[y][x]
 end
  
 def []=(*args)
   x, y, v = args
   cell_exists?(x, y) ? @field[y][x] = v : false
 end
end

class DrawPad
  attr_reader :atoms 
	
  def initialize(app)
    @app = app
    @atoms = []
    @inCircle = false
  end
	
  def paint()
    @app.clear
    @app.background 'pat101_21.png'
    @app.flow :margin => 3 do
      @fileName = @app.edit_line
      @app.button("Save") {
        alert @atoms.to_s
        if @fileName.text != ""
          fn = @fileName.text
        else 
          fn = "srep_temp"
        end
        File.open(fn + '.txt','w') {|file|
	  file.write (@atoms.to_s)
	  file.close}
      }
      @app.button("Undo") {
        if(@atoms.size > 0)
	  @atoms.pop
        end
        @inCircle = false
	  refresh }
     end
     @app.nofill
     atoms.each do |atom|
       @app.oval atom[0]-atom[2]/2, atom[1]-atom[2]/2, atom[2]
     end
   end
	
   def addAtom()
		
   end
	
   def refresh()
     paint
     @app.click do |button, left, top|
       if @inCircle == false
	 @atoms << [left, top, 10]
	 @inCircle = true
	 paint
       else 
	 @atoms.last[2] = @atoms.last[2] + 1.5
	 paint
       end
   end
   @app.keypress do |k|
     if "#{k.inspect}".to_s == "g"
     else
       @inCircle = false
     end
   end
 end
	
end 

Shoes.app :width => 1000, :height => 800, :title => '2d multi object' do
  def render_field
    clear do
      background rgb(50, 50, 90, 0.7)
      flow :margin => 6 do
	button("Srep Image"){
	  window :title => "draw srep", :width => 402, :height => 375 do
	    dp = DrawPad.new self
	    dp.refresh
          end
	}

        button("Dilate") { 
	  @sreps.each do |srep|
	    srep.atoms.each do |atom|
	      atom.dilate(1.05)
	    end
	  end
          refresh @points, @sreps, @shifts 
        }

	button("Reset") {
	  @dontGrowLst= []
	  initialConfig
	}

	button("Move") {
	  @shifts[0] = @shifts[0] + 10
	  refresh @points, @sreps, @shifts
	}

	button("Rotate") {
	  rotateSrep(@sreps[0], Math::PI/6)
	  refresh @points, @sreps, @shifts
	}

	button("Link") {
	  flag = 0
	  count = 0
	  while flag == 0
	    @sreps.each.with_index do |srep, j|
	      if j == 0
		srep.each.with_index do |a, i|
		  if @field.totalCorreLst[i][0] == 0 
		    a[2][0] = a[2][0] * 1.05
		  end
	        end
	      else 
		srep.each.with_index do |a, i|
		  @field.totalCorreLst.size.times do |k|
		    if @field.totalCorreLst[k][1] == i
		      @dontGrowLst << [j,i]
		      break
		    elsif !( @dontGrowLst.include? [j,i] )
		      a[2][0] = a[2][0] * 1.05
		      break
		    end
		  end
		end
	      end
	    end
	    refresh @points, @sreps, @shifts
	    count = @field.getHowManyColored
	    if count >= 7
	      flag = 1
	    end
          end
	}

	button("Save"){
	  fileName = 'pat101_31_par_link.txt'
	  File.open(fileName,'w') {|file|
	    file.write (@field.totalCorreLst.to_s)
	    file.close}
	}

     end
     stack do @status = para :stroke => black end
     @field.paint
     para @field.totalCorreLst.to_s
     para "\n"
     @field.sreps.each do |srep|
       rLst = []
       srep.atoms.each do |atom|
	 rLst << atom.spoke_length[0].ceil
       end
       para rLst.to_s
       para "\n"
     end
   end  
 end
  
def refresh points, sreps, shifts
  self.nofill
  @field = Field.new self, points, sreps, shifts
  render_field
end
  
def initialConfig
  points = [[50,100],[100,75],[150,50],[200,60],[250,80]]
  l = [[35,35,35],[35,35],[35,35],[40,40],[35,35,35]]
  u = [[[-1,3],[-1,-4],[-9,1]],[[-1,4],[-1,-5]],[[-1,4],[-1,-6]],[[1,9],[1,-8]],[[1,2],[1,-5],[6,1]]]
  @sreps = [generate2DDiscreteSrep(points,l,u)]
 # alert(@sreps.atoms[0])
	  #~ @binpoints = generateBinary(128,20,15,64,64,0.0,0.0)
	  #~ @points= binaryToPointList(@binpoints, 128)
	  # the first srep in the list is the reference object
  @shifts = [100, 100, 100]
	# @sreps = [generateStraight2DDiscreteSrep(50,35,64,64,256,9)]
	  # @sreps <<  generateStraight2DDiscreteSrep(50,30,64,64,256,9)
	#   @sreps =[  generateStraight2DDiscreteSrep(50,30,64,64,256,9)]
	#@sreps = [parseSavedSrep('pat101_31_par.txt')]
	#	@sreps << parseSavedSrep('pat101_31_man.txt')
	#	@sreps << parseSavedSrep('pat101_31_mas.txt')
		
	  #~ @sreps << generateStraight2DDiscreteSrep(50,35,64,64,256,9)
	  #~ @sreps << generateStraight2DDiscreteSrep(50,35,64,64,256,9)
	  #~ rotateSrep(@sreps[0], -Math::PI/6)
  refresh @points, @sreps, @shifts
 end
  
 @dontGrowLst = []
 initialConfig
end
