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

  attr_accessor :sreps, :shifts, :totalCorreLst, :interpBegin, :interpEnd 
  
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
    @totalCorreLst = []
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
    @app.stroke color
    if type == 'end'
       @app.line(cx, cy, cx + spoke_length[0] * spoke_direction[0][0], cy - spoke_length[0] * spoke_direction[0][1])
       @app.line(cx, cy, cx + spoke_length[1] * spoke_direction[1][0], cy - spoke_length[1] * spoke_direction[1][1])
       @app.line(cx, cy, cx + spoke_length[2] * spoke_direction[2][0], cy - spoke_length[2] * spoke_direction[2][1])
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
    show_curve = args[6]
    if args.length == 7
      totalCorreLst = args[7]
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
    
    if show_curve
      # display the interpolated curve points (gamma) 
      render_curve(srep.index, srep, shiftx, shifty)
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
      interpolateSkeletalCurveGamma(xt,yt,step_size,srep.index)
      gamma_file = File.open(file_name, "r")
    end 
    xsa = gamma_file.gets.split(" ")
    ysa = gamma_file.gets.split(" ") 
    xs = xsa.collect{|x| x.to_f}
    ys = ysa.collect{|y| y.to_f}
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
    @totalCorreLst = checkRefSrepIntersection

    @sreps.each.with_index do |srep, i|
      if i == 0 #=> reference obj
	render_srep(srep, 200 + @shifts[i] , 200 + @shifts[i] , @colorLst[i], 1.5, true, true, @totalCorreLst)
      else
	render_srep(srep, 200 + @shifts[i] , 200 + @shifts[i] , @colorLst[i], 1.5, true, true) 
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

          indices = []
          points = [[50,100],[100,75],[150,50],[200,60],[250,80]]
          indices << 0
          points.each_with_index do |p, i|
            if i != 0 && i != points.length-1
              v = xt.collect{|x| (x-p[0]).abs }.each_with_index.min
              indices << v[1]
            end
          end
          indices << xt.length-1

          kappa,kt = computeBaseKappa(xt,yt, indices, h, rr)
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
	  @sreps.each do |srep|
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
          dt = 0.01
          # ---
          # calculate parameters......
          # this time we read the file
          # read all points, rs, logrkm1s
          file = File.open('interpolated_points_0', 'r')
          xt = file.gets.split(' ').collect{|x| x.to_f}
	  yt = file.gets.split(' ').collect{|y| y.to_f}
          file = File.open('interpolated_rs_0', 'r')
	  rt = file.gets.split(' ').collect{|r| r.to_f}
	  file = File.open('interpolated_logrkm1s_0', 'r')
          logrkm1 = file.gets.split(' ').collect{|logrkm1| logrkm1.to_f}
          ## ---
          indices = []
           points = [[50,100],[100,75],[150,50],[200,60],[250,80]]
          indices << 0
          # calculate the indices of base points 
          points.each_with_index do |p, i|
            if i != 0 && i != points.length-1
              v = xt.collect{|x| (x-p[0]).abs }.each_with_index.min
              indices << v[1]
            end
          end
          indices << xt.length-1
          #-- 
          vt = [xt[indices[1]+1+$count] - xt[indices[1]+$count], yt[indices[1]+1+$count] - yt[indices[1]+$count]]
          size_vt = vt[0]**2 + vt[1]**2
          norm_vt = vt.collect{|v| v / size_vt} 
          
          kt = ( 1 + ( -1 * Math.exp(logrkm1[indices[1]]) ) ) / rt[indices[1]+$count] 
          dt = 0.01
          u01 = interpolateSpokeAtPos($u1, norm_vt, kt, dt)
          puts "u01: " + u01.to_s
          $u1 = u01
          $interpBegin << [xt[indices[1]+$count]+vt[0]*0.01,yt[indices[1]+$count]+vt[1]*0.01]
          puts "rt: " + rt[indices[1]+$count].to_s
          $interpEnd <<  [xt[indices[1]+$count]+vt[0]*0.01+u01[0]*rt[indices[1]+1+$count],yt[indices[1]+$count]+vt[1]*0.01+u01[1]*rt[indices[1]+1+$count]]
          puts "interpEnd: "+ $interpEnd[$count].to_s
          $count = $count + 1
          puts "count: "+ $count.to_s
          refresh @points, $sreps, @shifts, $interpBegin, $interpEnd
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
  
def refresh points, sreps, shifts, interpBegin, interpEnd
  self.nofill
  @field = Field.new self, points, sreps, shifts, interpBegin, interpEnd
  render_field
end
  
def initialConfig
  points = [[50,100],[100,75],[150,50],[200,60],[250,80]]
  l = [[35,35,35],[40,40],[45,45],[40,40],[35,35,35]]
  u = [[[-1,3],[-1,-4],[-9,1]],[[-1,4],[-1,-5]],[[-1,4],[-1,-6]],[[1,9],[1,-8]],[[1,2],[1,-5],[6,1]]]
  srep0 = generate2DDiscreteSrep(points,l,u)
  srep0.index = 0;
  $sreps = [srep0]
  $u1 = $sreps[0].atoms[1].spoke_direction[0]
  $count = 0
  @shifts = [100, 100, 100]
  $interpBegin = []
  $interpEnd = []

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
