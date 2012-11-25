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

  attr_accessor :sreps, :shifts, :interpBegin, :interpEnd 
  
  def initialize(app, points, sreps, shifts, interpBegin, interpEnd)
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
    @interpBegin = interpBegin
    @interpEnd = interpEnd
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

 # white: spoke zero
# black: spoke 1
    @app.stroke color
    if type == 'end'
    @app.stroke "#FFFFFF"
       @app.line(cx, cy, cx + spoke_length[0] * spoke_direction[0][0], cy - spoke_length[0] * spoke_direction[0][1])
    @app.stroke color
       @app.line(cx, cy, cx + spoke_length[1] * spoke_direction[1][0], cy - spoke_length[1] * spoke_direction[1][1])
    @app.stroke "#00FFFF"
       @app.line(cx, cy, cx + spoke_length[2] * spoke_direction[2][0], cy - spoke_length[2] * spoke_direction[2][1])
    elsif type == 'inner'
 @app.stroke "#FFFFFF"
       @app.line(cx, cy, cx + spoke_length[0] * spoke_direction[0][0], cy - spoke_length[0] * spoke_direction[0][1])
        @app.stroke color
       @app.line(cx, cy, cx + spoke_length[1] * spoke_direction[1][0], cy - spoke_length[1] * spoke_direction[1][1])
    end
  end

  def render_srep(*args)
    srep = args[0]
    shiftx  = args[1]
    shifty = args[2]
    scale = args[4]
    show_sphere = args[5]
    show_curve = args[6]
      
    if show_curve
      # display the interpolated curve points (gamma) 
      render_curve(srep.index, srep, shiftx, shifty)
    end
    srep.atoms.each_with_index do |atom|

      render_atom(atom.x + shiftx, atom.y + shifty, atom.corresponding_color)

      if show_sphere
	render_circle(atom.x + shiftx - atom.spoke_length[0], atom.y + shifty - atom.spoke_length[0], atom.spoke_length[0] * 2 , srep.color)
      end
      render_spokes(atom.x+shiftx, atom.y+shifty, atom.type, atom.spoke_length, atom.spoke_direction, srep.color)
    end
  

    if @interpBegin.length > 0
      puts "render_interp_spokes"
      render_interp_spokes(shiftx, shifty, '#FFFFFF')
    end
  end 
  
  def render_curve(index, srep, shiftx, shifty)
    file_name = "interpolated_points_" + index.to_s
    if File::exists?(file_name)
      gamma_file = File.open(file_name, "r")
    else
      alert('file does not exist, interpolate it now')
      xt = srep.atoms.collect{|atom| atom.x}
      yt = srep.atoms.collect{|atom| atom.y}
      step_size = 0.01
      interpolateSkeletalCurveGamma(xt,yt,step_size,srep.sreindex)
      gamma_file = File.open(file_name, "r")
    end 
    xs = gamma_file.gets.split(" ").collect{|x| x.to_f}
    ys = gamma_file.gets.split(" ").collect{|y| y.to_f}
    xs.each_with_index do |x,i|
      render_atom(x+shiftx,ys[i]+shifty,"#000000")
    end
  end

  def render_interp_spokes(shiftx, shifty, color)
    @app.stroke color
    @interpBegin.each_with_index do |p, i|
       @app.line(p[0]+shiftx, p[1]+shifty, interpEnd[i][0]+shiftx, interpEnd[i][1]+shifty)
    end
  end

  def render_atom(x, y, color)
      render_point_big(x, y, color)
  end
  
  def paint
    @app.nostroke
    checkSrepIntersection

    $sreps.each.with_index do |srep, i|
      render_srep(srep, 200 + @shifts[i] , 200 + @shifts[i] , @colorLst[i], 1.5, true, srep.show_curve)
    end
  end  
 
  def checkSrepIntersection
   (0..$sreps.length-1).each do |j|
    (0..$sreps.length-1).each do |i|
      if i != j
        $sreps[j].checkIntersection($sreps[i])
       end
    end
   end
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

class InterpolateControl
	
  attr_accessor :app, :index, :msg
  def initialize(app)
    @app = app
   refresh
  end
	
  def paint()
    @app.clear
    @app.flow :margin => 3 do
      @app.button("Check") {
      	if checkIndexEmpty()
          @msg.text = "empty index!"
        else
          file_name = "interpolated_radius_" + @index.text
          @msg.text = "file existing: "+  File::exists?(file_name).to_s
        end
      }
      @app.button("Interpolate") {
      # interpolate radius
          index = @index.text
          srep =  $sreps[index.to_i]
          xt = srep.atoms.collect{|atom| atom.x.to_s}
          rt = srep.atoms.collect{|atom| atom.spoke_length[0].to_s} 
          step_size = 0.01
          rs = interpolateRadius(xt,rt,step_size,index)
          rr = rs.strip.split(' ').collect{|r| r.to_f} 
      # interpolate kappa
          # read interpolated file
          step_size = 0.01
          # rt and kt are the r's and k's on the base points 
          # need to calculate kappa at base positions using the curvature formula

          f = File.new('interpolated_points_'+ index, 'r')   
          xs = f.gets.strip.split(' ')
          ys = f.gets.strip.split(' ')  
          xt = []
          xs.each do |x|
            xt << x.to_f
          end
          yt = []
          ys.each do |y|
            yt << y.to_f
          end
          h = step_size
          f.close
          ff = File.new('interpolated_rs_0', 'r')
          rs = ff.gets.strip.split(' ')
          puts "rr: " + rr.to_s

          indices= srep.base_index
          
          foo = computeBaseKappa(xt,yt, indices, h, rr)
          kappa = foo[0]
          rt = srep.atoms.collect{|atom| atom.spoke_length[0]} 
          puts "inside 2: rt: " + rt.to_s   
          puts "inside 3: kt: " + kappa.to_s 
          interpolateKappa(rt, kappa, step_size, index)
      }
   end
   @app.stack :margin => 3 do 
       @app.para "enter the index of the srep"
       @index = @app.edit_line :width => 50
       @msg = @app.para "hi"
     end
     @app.nofill
   end

   def refresh
     paint
   end
	
   def checkIndexEmpty()
     return @index.text.strip() == ""
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
	  $sreps.each do |srep|
	    srep.atoms.each do |atom|
	      atom.dilate(1.05)
	    end
	  end
          refresh @points, $sreps, @shifts, $interpBegin, $interpEnd
        }

	button("Reset") {
	  @dontGrowLst= []
	  initialConfig
	}

	button("Move") {
	  @shifts[0] = @shifts[0] + 10
	  refresh @points, $sreps, @shifts, $interpBegin, $interpEnd
	}

	button("Rotate") {
	  rotateSrep(@sreps[0], Math::PI/6)
	  refresh @points, $sreps, @shifts, $interpBegin, $interpEnd
	}

	button("Link") {
	  flag = 0
	  count = 0
	  while flag == 0
	    @sreps.each.with_index do |srep, j|
	      if j == 0
	#	srep.each.with_index do |a, i|
	#	  if @field.totalCorreLst[i][0] == 0 
	#	    a[2][0] = a[2][0] * 1.05
	#	  end
	 #       end
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
	    refresh @points, $sreps, @shifts, $interpBegin, $interpEnd
	    count = @field.getHowManyColored
	    if count >= 7
	      flag = 1
	    end
          end
	}

	button("Save") {
	  fileName = 'pat101_31_par_link.txt'
	  File.open(fileName,'w') {|file|
	    file.write (@field.totalCorreLst.to_s)
	    file.close}
	}
 
        button("Check r-k File") {
          window :title => "draw srep", :width => 402, :height => 375 do
	    dp = InterpolateControl.new(self)
          end
        }

 	button("interpolate from index 1") {    
          indices = $sreps[0].base_index
          foo = $bar
          c1 = ( indices[foo+1] - indices[foo] ) - $count 
          if c1 == 0
            $count = 0
            $bar = $bar +1    
            c1 = ( indices[foo+1] - indices[foo] ) - $count 
          foo = $bar
          end
          d1t = 0.01 * $count
          d2t = c1 * 0.01 

          
          # ---
          # calculate parameters......
          # read all points, rs, logrkm1s from the file
          file = File.open('interpolated_points_0', 'r')
          xt = file.gets.split(' ').collect{|x| x.to_f}
	  yt = file.gets.split(' ').collect{|y| y.to_f}
          file = File.open('interpolated_rs_0', 'r')
	  rt = file.gets.split(' ').collect{|r| r.to_f}
	  file = File.open('interpolated_logrkm1s_0', 'r')
          logrkm1 = file.gets.split(' ').collect{|logrkm1| logrkm1.to_f}
          ## ---

          #-- 
          v1t = [xt[indices[foo]+$count+1] - xt[indices[foo]], yt[indices[foo]+$count+1] - yt[indices[foo]]]
          v2t = [xt[indices[foo+1]] - xt[indices[foo]+$count], yt[indices[foo+1]] - yt[indices[foo]+$count]]
          
          puts "v1t: " + v1t.to_s
          size_v1t = v1t[0]**2 + v1t[1]**2
          norm_v1t = v1t.collect{|v| v / size_v1t} 
          size_v2t = v2t[0]**2 + v2t[1]**2
          norm_v2t = v2t.collect{|v| v / size_v2t} 
          
          k1t = ( 1 + ( -1 * Math.exp(logrkm1[indices[foo]]   ) ) ) / rt[indices[foo]] 
          k2t = ( 1 + ( -1 * Math.exp(logrkm1[indices[foo+1]] ) ) ) / rt[indices[foo+1]] 
            
          u1t = $sreps[0].atoms[foo].spoke_direction[0]
          u2t = $sreps[0].atoms[foo+1].spoke_direction[0]
          ui = interpolateSpokeAtPos(u1t, norm_v1t, k1t, d1t, u2t, norm_v2t, k2t, d2t)
          puts "ui: " + ui.to_s
          $interpBegin << [xt[indices[foo]+$count+1],yt[indices[foo]+$count+1]]    
          puts "begin: " + $interpBegin.to_s
          puts "rt: " + rt[indices[foo]+$count].to_s
          $interpEnd <<  [xt[indices[foo]+$count+1]+ui[0]*rt[indices[foo]+1+$count],yt[indices[foo]+$count+1]-ui[1]*rt[indices[foo]+1+$count]]
          puts "interpEnd: "+ $interpEnd[$count].to_s
          $count = $count + 1
          puts "count: "+ $count.to_s
          refresh @points, $sreps, @shifts, $interpBegin, $interpEnd
        }
     end

     stack do @status = para :stroke => black end
     @field.paint
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
  
def refresh points, sreps, shifts, interpBegin, interpEnd
  self.nofill
  @field = Field.new self, points, sreps, shifts, interpBegin, interpEnd
  render_field
end
  
def initialConfig
  points0 = [[50,100],[100,75],[150,50],[200,60],[250,80]]
  l0 = [[35,35,35],[40,40],[50,50],[40,40],[35,35,35]]
  u0 = [[[-1,3],[-1,-4],[-9,1]],[[-1,4],[-1,-5]],[[-1,4],[-1,-6]],[[1,9],[1,-8]],[[1,2],[1,-5],[6,1]]]
  srep0 = generate2DDiscreteSrep(points0,l0,u0,0.01,0)
  $sreps = [srep0]
  $count = 0
  @shifts = [100, 100]
  $interpBegin = []
  $interpEnd = []
  $bar = 0
  points1 = [[150,200],[200,190],[250,200],[300,180],[350,180]]
  l1 = [[35,35,35],[40,40],[45,45],[40,40],[35,35,35]]
  u1 = [[[-1,3],[-1,-4],[-9,1]],[[-1,4],[-1,-5]],[[-1,4],[-1,-6]],[[1,9],[1,-8]],[[1,2],[1,-5],[6,1]]]
  srep1 = generate2DDiscreteSrep(points1,l1,u1,0.01,1)
  srep1.color = "#00FF66"
  $sreps << srep1
  
  # -----------keep out -----------
  # ----old initialization codes...
	# @sreps = [generateStraight2DDiscreteSrep(50,35,64,64,256,9)]
	  # @sreps <<  generateStraight2DDiscreteSrep(50,30,64,64,256,9)
	#   @sreps =[  generateStraight2DDiscreteSrep(50,30,64,64,256,9)]
	#@sreps = [parseSavedSrep('pat101_31_par.txt')]
	#	@sreps << parseSavedSrep('pat101_31_man.txt')
	#	@sreps << parseSavedSrep('pat101_31_mas.txt')
		
	  #~ @sreps << generateStraight2DDiscreteSrep(50,35,64,64,256,9)
	  #~ @sreps << generateStraight2DDiscreteSrep(50,35,64,64,256,9)
	  #~ rotateSrep(@sreps[0], -Math::PI/6)
	 # alert(@sreps.atoms[0])
	  #~ @binpoints = generateBinary(128,20,15,64,64,0.0,0.0)
	  #~ @points= binaryToPointList(@binpoints, 128)
	  # the first srep in the list is the reference object
  # ----------keep out-------------

  refresh @points, $sreps, @shifts, $interpBegin, $interpEnd
end
  
@dontGrowLst = []
initialConfig
end
