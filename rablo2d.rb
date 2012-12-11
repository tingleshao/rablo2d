load 'lib/srep_toolbox.rb'
load 'lib/color.rb'

$points_file_path = "data/interpolated_points_"
$radius_file_path = "data/interpolated_rs_"
$logrk_file_path = 'data/interpolated_logrkm1s_'
$dilate_ratio = 1.05

class Field

  attr_accessor :sreps, :shifts
  
  def initialize(app, points, sreps, shifts)
    @app = app
    # set window size
    @width, @height= 800, 600
    @sreps = sreps 
    @shifts = shifts
  end
  
  def setSrep(srep, index) 
    @sreps[index] = srep
  end
  
  def addSrep(srep) 
    @sreps << srep
  end
 
  def render_point_big(x, y, color)
    @app.stroke color
    @app.strokewidth 2
    @app.nofill
    @app.oval x-1,y-1, 2
  end

  def render_point_small(x, y, color, bg_color)
   @app.stroke color
   @app.line x, y, x, y+1
   @app.stroke bg_color
   @app.line x, y+1, x+1, y+1
  end
 
  def render_circle(cx, cy, d, color)
    @app.stroke color
    @app.nofill 
    @app.oval cx, cy, d
  end

  def render_spokes(cx, cy, type, spoke_length, spoke_direction, color)
    @app.stroke color
    u_p1 = spoke_direction[0]
    u_m1 = spoke_direction[1] 
    @app.stroke color
    spoke_end_x_up1 = cx + spoke_length[0] * u_p1[0]
    spoke_end_y_up1 = cy - spoke_length[0] * u_p1[1]
    @app.line(cx, cy, spoke_end_x_up1, spoke_end_y_up1)
    spoke_end_x_up2 = cx + spoke_length[1] * u_m1[0]
    spoke_end_y_up2 = cy - spoke_length[1] * u_m1[1]
    @app.line(cx, cy, spoke_end_x_up2, spoke_end_y_up2)
    if type == 'end'
    u_0 = spoke_direction[2]
    spoke_end_x_u0 = cx + spoke_length[2] * u_0[0]
    spoke_end_y_u0 = cy - spoke_length[2] * u_0[1]
    @app.line(cx, cy, spoke_end_x_u0, spoke_end_y_u0)
    end
  end

  def render_srep(*args)
    srep = args[0]
    shiftx  = args[1]
    shifty = args[2]
    scale = args[3]
    show_sphere = args[4]
      
    srep.atoms.each_with_index do |atom|
      render_atom(atom.x + shiftx, atom.y + shifty, atom.color)
      if show_sphere
        center_x = atom.x + shiftx - atom.spoke_length[0]
        center_y = atom.y + shifty - atom.spoke_length[0]
        d = atom.spoke_length[0] * 2
	render_circle(center_x, center_y, d, srep.color)
      end
      if srep.show_extend_disk
        center_x = atom.x + shiftx - atom.expand_spoke_length[0]
        center_y = atom.y + shifty - atom.expand_spoke_length[0]
        d = atom.expand_spoke_length[0] * 2 
        render_circle(center_x, center_y, d, srep.color)
      end 
      atom_x = atom.x+shiftx
      atom_y = atom.y+shifty
      render_spokes(atom_x, atom_y, atom.type, atom.spoke_length, atom.spoke_direction, srep.color)
    end

    if srep.interpolated_spokes_begin.length > 0 and srep.show_interpolated_spokes
      spoke_begin = srep.interpolated_spokes_begin
      spoke_end = srep.interpolated_spokes_end
      render_interp_spokes(shiftx, shifty, Color.white, spoke_begin, spoke_end)
    end

    if (srep.getExtendInterpolatedSpokesEnd()).length > 0 and srep.show_extend_spokes
      spoke_begin = srep.interpolated_spokes_end  
      spoke_end = srep.getExtendInterpolatedSpokesEnd()
      render_extend_interp_spokes(shiftx, shifty, Color.red, spoke_begin, spoke_end)
    end
    
    if srep.show_curve
      # display the interpolated curve points
      render_curve($sreps, srep.index, srep, shiftx, shifty)
    end
  end 
  
  def render_curve(sreps, index, srep, shiftx, shifty)
    file_name = $points_file_path + index.to_s
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
    xs = gamma_file.gets.split(" ").collect{|x| x.to_f}
    ys = gamma_file.gets.split(" ").collect{|y| y.to_f}
   
    if (srep.interpolate_finished)
      xs.each_with_index do |x,i|
        spoke_ind = i*2
        atom_type = srep.getExtendInterpolatedSpokesEnd()[spoke_ind][4]
        back_atom_type = srep.getExtendInterpolatedSpokesEnd()[spoke_ind+1][4]
        if atom_type != 'end' and back_atom_type != 'end'
          linkingIndex = srep.getExtendInterpolatedSpokesEnd()[spoke_ind][2]
          if linkingIndex == -1
            color1 = srep.color
          else 
            color1 = sreps[linkingIndex].color
          end
            linkingIndex = srep.getExtendInterpolatedSpokesEnd()[spoke_ind+1][2]
          if linkingIndex == -1
            color2 = srep.color
          else 
            color2 = sreps[linkingIndex].color
          end
        else 
          color1 = srep.color
          color2 = srep.color
        end
        render_atom(x+shiftx,ys[i]+shifty, color1)
        render_atom(x+shiftx+1, ys[i]+shifty-1, color2)
      end
    else 
      xs.each_with_index do |x,i|
        render_atom(x+shiftx,ys[i]+shifty, srep.color)
        render_atom(x+shiftx+1, ys[i]+shifty-1, srep.color)
      end
    end
  end

  def render_interp_spokes(shiftx, shifty, color, ibegin, iend)
    @app.stroke color
    ibegin.each_with_index do |p, i|
       @app.line(p[0]+shiftx, p[1]+shifty, iend[i][0]+shiftx, iend[i][1]+shifty)
    end
  end
   
  def render_extend_interp_spokes(shiftx, shifty, color, ibegin, iend)
    @app.stroke color
    iend.each_with_index do |p, i|
      @app.line(ibegin[i][0]+shiftx, ibegin[i][1]+shifty, p[0]+shiftx, p[1]+shifty)
    end
  end
  
  def render_atom(x, y, color)
    render_point_big(x, y, color)
  end
  
  def render_linking_structure(shifts)
     shift = shifts[0]
     $linkingPts.each do |pt|
       render_atom(pt[0]+shift, pt[1]+shift, Color.black)
     end
  end

  def paint
    @app.nostroke
    checkSrepIntersection

    $sreps.each.with_index do |srep, i|
      render_srep(srep, @shifts[i] , @shifts[i] , 1.5, true)
    end

    if $show_linking_structure 
       render_linking_structure(@shifts)
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
          file_name = $radius_file_path + @index.text
          @msg.text = "file exists: "+  File::exists?(file_name).to_s
        end
      }
      @app.button("Interpolate") {
      # interpolate radius
          index = @index.text
          srep =  $sreps[index.to_i]
          xt = srep.atoms.collect{|atom| atom.x}
          yt = srep.atoms.collect{|atom| atom.y}
          rt = srep.atoms.collect{|atom| atom.spoke_length[0].to_s} 
          step_size = 0.01
          rs = interpolateRadius(xt,yt,rt,step_size,index)
          rr = rs.strip.split(' ').collect{|r| r.to_f} 
          # interpolate kappa
          # read interpolated file
          step_size = 0.01
          # rt and kt are the r's and k's on the base points 
          # calculate kappa at base positions using the curvature formula
          f = File.new($points_file_path+ index, 'r')   
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
          ff = File.new($radius_file_path+index, 'r')
          rs = ff.gets.strip.split(' ')
          indices= srep.base_index
          foo = computeBaseKappa(xt,yt, indices, h, rr)
          kappa = foo[0]
          rt = srep.atoms.collect{|atom| atom.spoke_length[0]} 
          interpolateKappa(rt, kappa, step_size, index)
      }
   end
   @app.stack :margin => 3 do 
       @app.para "enter the index of the srep"
       @index = @app.edit_line :width => 50
       @msg = @app.para ""
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

        button("Dilate") { 
	  $sreps.each do |srep|
	    srep.atoms.each do |atom|
	      atom.dilate($dilate_ratio)
	    end
            # dilate interpolated spokes
            # and check intersection 
            # user can specify first serval count to speed up dilate
            if $dilateCount > 6
              srep.extendInterpolatedSpokes($dilate_ratio, $sreps, true)
            else
              srep.extendInterpolatedSpokes($dilate_ratio, $sreps, false)
            end
	  end
          $dilateCount = $dilateCount + 1
          refresh @points, $sreps, @shifts
        }

	button("Reset") {
	  @dontGrowLst= []
	  initialConfig
	}

        button("Check r-k File") {
          window :title => "draw srep", :width => 402, :height => 375 do
	    dp = InterpolateControl.new(self)
          end
        }

        button("Curve Visibility") {
          $sreps.each do |srep| 
             srep.show_curve = !srep.show_curve
          end
          refresh @points, $sreps, @shifts
        }
  
        button("Interpolated Spokes Visbility") {
          $sreps.each do |srep| 
             srep.show_interpolated_spokes = !srep.show_interpolated_spokes
          end
          refresh @points, $sreps, @shifts
        }

        button("Extend Spokes Visibility") {
          $sreps.each do |srep| 
             srep.show_extend_spokes = !srep.show_extend_spokes
          end
          refresh @points, $sreps, @shifts
        }

        button("Extend Disks Visibility") {
          $sreps.each do |srep| 
             srep.show_extend_disk = !srep.show_extend_disk
          end
          refresh @points, $sreps, @shifts
        }

        button("Show linking structure") {
          $linkingPts = []
          $sreps.each do |srep|
             srep.extend_interpolated_spokes_end.each_with_index do |spoke_end, i|
                if spoke_end[2] != -1 
                   $linkingPts << [spoke_end[0], spoke_end[1]]  
                end
             end
          end
          $show_linking_structure = true
          refresh @points, $sreps, @shifts
          linkLinkingStructurePoints($sreps, self, 300)          
	}
          
        button("Interpolate All") {
         $sreps.each_with_index do |srep, srep_index| 
           100.times do
             # interpolate one side
             indices = srep.base_index
             foo = $bar2
             c1 = ( indices[foo+1] - indices[foo] ) - $count2 
             if c1 == 0
               $count2 = 0
               $bar2 = $bar2 +1    
               c1 = ( indices[foo+1] - indices[foo] ) - $count2
               foo = $bar2
             end
          
             curr_index = indices[foo] + $count2 + 1 
             puts "curr_index: " + curr_index.to_s
            
             d1t = 0.01 * $count2
             d2t = c1 * 0.01 

             # calculate parameters
             # read all points, rs, logrkm1s from the file
             file = File.open($points_file_path + srep_index.to_s, 'r')
             xt = file.gets.split(' ').collect{|x| x.to_f}
	     yt = file.gets.split(' ').collect{|y| y.to_f}
             file = File.open($radius_file_path + srep_index.to_s, 'r')
    	     rt = file.gets.split(' ').collect{|r| r.to_f}
             file = File.open($logrk_file_path + srep_index.to_s, 'r')
             logrkm1 = file.gets.split(' ').collect{|logrkm1| logrkm1.to_f}

             if curr_index < xt.length-1
               v1t = [xt[curr_index] - xt[indices[foo]], yt[curr_index] - yt[indices[foo]]]
               if curr_index == indices[foo+1]
                 v2t = [xt[indices[foo+1]+1] - xt[curr_index], yt[indices[foo+1]+1] - yt[curr_index]]
               else
                 v2t = [xt[indices[foo+1]] - xt[curr_index], yt[indices[foo+1]] - yt[curr_index]]
               end
               puts "v1t: " + v1t.to_s
               size_v1t = v1t[0]**2 + v1t[1]**2
               norm_v1t = v1t.collect{|v| v / size_v1t} 
 
               size_v2t = v2t[0]**2 + v2t[1]**2
               puts "size_v2t: " + size_v2t.to_s
               norm_v2t = v2t.collect{|v| v / size_v2t} 
          
               k1t = ( 1 + ( -1 * Math.exp(logrkm1[indices[foo]]   ) ) ) / rt[indices[foo]] 
               k2t = ( 1 + ( -1 * Math.exp(logrkm1[indices[foo+1]] ) ) ) / rt[indices[foo+1]] 
            
               u1t = srep.atoms[foo].spoke_direction[0]
               u2t = srep.atoms[foo+1].spoke_direction[0]
               ui = interpolateSpokeAtPos(u1t, norm_v1t, k1t, d1t, u2t, norm_v2t, k2t, d2t)
               puts "ui: " + ui.to_s
               srep.interpolated_spokes_begin << [xt[curr_index],yt[curr_index],-1]    
               puts "rt: " + rt[curr_index-1].to_s
               srep.interpolated_spokes_end  <<  [xt[curr_index]+ui[0]*rt[curr_index],yt[curr_index]-ui[1]*rt[curr_index],-1,[],'regular']
               # interpolate another side
               u1t = $sreps[srep_index].atoms[foo].spoke_direction[1]
               u2t = $sreps[srep_index].atoms[foo+1].spoke_direction[1]
               ui = interpolateSpokeAtPos(u1t, norm_v1t, k1t, d1t, u2t, norm_v2t, k2t, d2t)
               puts "ui: " + ui.to_s
               $sreps[srep_index].interpolated_spokes_begin << [xt[indices[foo]+$count2+1],yt[indices[foo]+$count2+1],-1,[],'regular']    
               puts "rt: " + rt[indices[foo]+$count2].to_s
               $sreps[srep_index].interpolated_spokes_end  <<  [xt[indices[foo]+$count2+1]+ui[0]*rt[indices[foo]+1+$count2],yt[indices[foo]+$count2+1]-ui[1]*rt[indices[foo]+1+$count2],-1]
             else
               # add spoke interpolation for end disks
               # get atom for end disks
               end_atom_one = srep.atoms[0]
               end_atom_two = srep.atoms[-1]
               end_atoms = [end_atom_one, end_atom_two]
               # get upper and lower and middle disks 
               end_atoms.each_with_index do |atom, i|
                 atom_spoke_dir_plus1 = atom.spoke_direction[0]
                 atom_spoke_dir_minus1 = atom.spoke_direction[1]
                 atom_spoke_dir_zero = atom.spoke_direction[2]
                 x_diff_1 = atom_spoke_dir_zero[0] - atom_spoke_dir_plus1[0]
                 x_diff_2 = atom_spoke_dir_zero[0] - atom_spoke_dir_minus1[0]
                 y_diff_1 = atom_spoke_dir_zero[1] - atom_spoke_dir_plus1[1]
                 y_diff_2 = atom_spoke_dir_zero[1] - atom_spoke_dir_minus1[1]
                 x_step_size_1 = x_diff_1.to_f / 15
                 y_step_size_1 = y_diff_1.to_f / 15
                 x_step_size_2 = x_diff_2.to_f / 15
                 y_step_size_2 = y_diff_2.to_f / 15
                 previous_x = atom_spoke_dir_plus1[0] 
                 previous_y = atom_spoke_dir_plus1[1] 
                 20.times do 
                   new_spoke_dir_x = previous_x + x_step_size_1
                   new_spoke_dir_y = previous_y + y_step_size_1
                   # normalize 
                   length_new_spoke = Math.sqrt(new_spoke_dir_x**2 + new_spoke_dir_y**2)
                   new_spoke_dir_x = new_spoke_dir_x / length_new_spoke
                   new_spoke_dir_y = new_spoke_dir_y / length_new_spoke
                   previous_x = new_spoke_dir_x
                   previous_y = new_spoke_dir_y
                   # calculate interpolated spoke end
                   new_spoke_end = [atom.x + atom.spoke_length[0]*new_spoke_dir_x, atom.y - atom.spoke_length[0]*new_spoke_dir_y,-1,[],'end']
                   $sreps[srep_index].interpolated_spokes_begin << [atom.x, atom.y]
                   $sreps[srep_index].interpolated_spokes_end << new_spoke_end
                 end
                 previous_x = atom_spoke_dir_minus1[0]
                 previous_y = atom_spoke_dir_minus1[1]
                 20.times do 
                   new_spoke_dir_x = previous_x + x_step_size_2
                   new_spoke_dir_y = previous_y + y_step_size_2
                   # normalize 
                   length_new_spoke = Math.sqrt(new_spoke_dir_x**2 + new_spoke_dir_y**2)
                   new_spoke_dir_x = new_spoke_dir_x / length_new_spoke
                   new_spoke_dir_y = new_spoke_dir_y / length_new_spoke
                   previous_x = new_spoke_dir_x
                   previous_y = new_spoke_dir_y
                   # calculate interpolated spoke end
                   new_spoke_end = [atom.x + atom.spoke_length[0]*new_spoke_dir_x, atom.y - atom.spoke_length[0]*new_spoke_dir_y,-1,[],'end']
                   $sreps[srep_index].interpolated_spokes_begin << [atom.x, atom.y]
                   $sreps[srep_index].interpolated_spokes_end << new_spoke_end
                   $sreps[srep_index].interpolate_finished = true
                 end
               end
               $info = "interpolation finished"
             end
             $count2 = $count2 + 1
             puts "count: "+ $count2.to_s
             
             refresh @points, $sreps, @shifts
           end
           $count2 = 0
           $bar2 = 0
         end
       }
     end

     stack do @status = para :stroke => black end
     @field.paint
     para "\n"
     para $info
   end  
 end
  
 def refresh points, sreps, shifts
   self.nofill
   @field = Field.new self, points, sreps, shifts
   render_field
 end
  
def initialConfig
   points0 = [[110,100],[160,75],[210,50],[260,60],[310,80]]
  l0 = [[35,35,35],[40,40],[50,50],[40,40],[35,35,35]]
  u0 = [[[-1,3],[-0.1,-4],[-9,1]],[[-1,4],[1.1,-3]],[[-1,4],[0.2,-6]],[[1,9],[0.05,-8]],[[1,2],[1,-5],[6,1]]]
  srep0 = generate2DDiscreteSrep(points0,l0,u0,0.01,0)
  $sreps = [srep0]
  $count2 = 0
  @shifts = [300,300,300]
  $bar2 = 0	
  $info = ""
  $dilateCount = 0
  points1 = [[200,190],[250,190],[300,200],[350,180],[400,160]]
  l1 = [[35,35,35],[40,40],[45,45],[40,40],[35,35,35]]
  u1 = [[[-1,6],[0.5,-3],[-9,1]],[[-1,4],[-1,-3]],[[-1,4],[-0.1,-6]],[[1,9],[1,-1.5]],[[1,2],[2,-5],[6,1]]]
  srep1 = generate2DDiscreteSrep(points1,l1,u1,0.01,1)
  srep1.color = Color.green
  $sreps << srep1
  points2 = [[30,50],[10,100],[9,150],[20,200],[50,240],[110,290]]
  l2 = [[35,35,35],[35,35],[40,40],[35,35],[40,40],[40,40,40]]
  u2 = [[[6,1],[6,-0.5],[-9,1]],[[-1,4],[3,-0.5]],[[-1,4],[5,-0.5]],[[1,9],[5,1]],[[1,9],[5,3]],[[1,2],[3,5],[6,1]]]
  srep2 = generate2DDiscreteSrep(points2,l2,u2,0.01,2)
  srep2.color = Color.purple
  $sreps << srep2
  $linkingPts = []
  $show_linking_structure = false
   
  refresh @points, $sreps, @shifts
end
  
initialConfig
end


