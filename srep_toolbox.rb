#load 'image_toolbox.rb'
load 'srep.rb'
load 'atom.rb'

$pi = Math::PI

def generateStraight2DDiscreteSrep(rx,ry,cx,cy,size,nOfatomDiv2Minus1)
  mr = (rx**2 - ry**2).to_f / rx
  noadm = nOfatomDiv2Minus1
  # hand code the u's 
  m = []
  angle = [$pi*2/3, $pi*11/18, $pi*5/9, $pi/2, $pi*4/9, $pi*7/18, $pi/3] *  (noadm /3)
  #~ alert angle
  for i in -noadm..noadm
    a = []
    # calculate p
    step = mr/(noadm)
    p = [cx-step*i, cy]
    # calculate u0, u1, u2
    sx = Math.cos(angle[i+noadm])
    sy = Math.sin(angle[i+noadm])
    u0 = [sx, sy]
    u1 = [sx, -1*sy]
    if i == noadm then u2 = [1,0] else u2 = [-1,0] end
    u = [u0, u1, u2]
    # calculate r0, r1, r2
    # now don't calculate, just set they all the same.
    puts "rx: " + rx.to_s + "mr: " + mr.to_s
    r_same = (rx - mr ) *2
    r0 = r1 = r_same *  3.0/7 * Math.log(noadm * 2 +10- i.abs)
    #~ r0 = r1 = r_same
    if i == -noadm then r2  = r_same  elsif i == noadm then r2 = r_same else r2 = 0 end
    r = [r0, r1, r2]
    a = [p, u, r]
    puts "r: " + r.to_s
    m << a
  end
  return m
end

def generate2DDiscreteSrep(atoms, spoke_length, spoke_direction)
  # the atoms is passed as a list of x-y's 
  # should generate atom objects for that
  srep = SRep.new()	
  atoms.each_with_index do |atom, i|
    if spoke_length[i].length == 3
	type = 'end'
    else
	type = 'inner'
    end
    # normalize the u vector
    usi = spoke_direction[i]
    usi.each_with_index do |ui, index|
      usi[index] = [Float(ui[0]),Float(ui[1])]
    end
    usi.each_with_index do |ui, index|
      x = ui[0]
      y = ui[1]
      ui.each_with_index do |foo, index2|
        ui[index2] = foo / Math.sqrt(x**2+y**2)
   #     puts "foo: " + foo.to_s
   #     puts "ui: " + ui[index2].to_s
      end
    end 
 #   puts usi
    # make sure the spoke length vector is in type Float
    li = spoke_length[i]
    li.each_with_index do |l, index|
      li[index] = Float(l)
    end
    # make sure the positions x-y is in type Float
    atom.each_with_index do |foo, index|
	atom[index] = Float(foo)
    end
    atomO = Atom.new(li, usi, type, atom[0], atom[1], '#000000')
    srep.atoms.push(atomO)
  end
  srep.color = '#000000'
  return srep
end


def generate2DDiscreteSrepC(atoms, spoke_length, spoke_direction, curves)
	# this method returns the s-rep object by taking the discrete atoms position, spokes and dense discrete curve points as parameters
	
end

def generate2DDiscreteSrepBySampledPointsC(atoms, spoke_length, spoke_direction)
	# this method would firstly call the spline interpolation method to intepolate the curve
	
end



def rotateSrep(srep, angle)
	# rotate the srep, with the rotation cencter being the srep's center
	if srep.size % 2 ==1 then centerP = srep[srep.size / 2][0] else centerP = [(srep[srep.size/2 -1][0][0] + srep[srep.size/2][0][0]), (srep[srep.size/2 -1][0][1] + srep[srep.size/2][0][1])] end
	cx = centerP[0]
	cy = centerP[1]
	srep.each do |a|
		p = a[0]
		#~ alert "P: " + p.to_s
		#~ alert "centerP: "+ cx.to_s + " " + cy.to_s
		newP = rotateOneAtom(cx, cy, p[0], p[1], angle)
		a[0][0] = newP[0]
		a[0][1] = newP[1]
		#~ alert "a: " + a.to_s
	end
	return srep
end

def moveAtomPositionByClick(srep, atomIndex, translationVector)
	
end

def rotateOneAtom(cX, cY, xx, yy, angle)
  if (cX.to_f != xx.to_f)
    # theta is the angle in radius
    # phi is the x, y old angle reltative to horizontal
    x = xx.to_f
    y = yy.to_f
    centerX = cX.to_f
    centerY = cY.to_f
    relativeX = x - centerX
    relativeY = y - centerY
    r = Math.sqrt(relativeX**2 + relativeY**2)
    cosphi = relativeX / r
    sinphi = relativeY / r
    cosThetaPlusPhi = Math.cos(angle) * cosphi - Math.sin(angle) * sinphi
    d1 = r * cosThetaPlusPhi 
    newX = centerX + d1
    sinThetaPlusPhi = Math.sin(angle) * cosphi + Math.cos(angle) * sinphi 
    d3 = r * sinThetaPlusPhi
    newY = y + d3
    newP = [newX, newY]
  else 
    newP = [xx, yy]
  end
  return newP
end

def checkSrepIntersection(srep1, srep2, shift1, shift2)
	# returns a list indicates that for each atom in srep1, what is the correspoinding neighbor srep color 
	correLst = []
	srep1.each.with_index do |atom1, j|
		correLst << [0, nil]
		atom1posX = atom1[0][0] + shift1
		atom1posY = atom1[0][1] + shift1
		srep2_0PosX = srep2[0][0][0] + shift2
		srep2_0PosY = srep2[0][0][1] + shift2
		minDistSoFar = getDistance(atom1posX, atom1posY, srep2_0PosX, srep2_0PosY)
		distToSrep2_0 = atom1[2][0] /2+ srep2[0][2][0] /2
		if minDistSoFar < distToSrep2_0
			correLst[j] = [1,0]
		end
		srep2.each.with_index do |atom2, i|
			atom2posX = atom2[0][0] + shift2
			atom2posY = atom2[0][1] + shift2
			# now asssume all three r's for one atom are equivalent to each other (medial case)
			r1PlusR2 = atom1[2][0]/2 + atom2[2][0] /2
			dist =  getDistance(atom1posX, atom1posY, atom2posX, atom2posY) 
			if dist < r1PlusR2 
				if dist < minDistSoFar
					correLst[j] = [1, i]
					minDistSoFar = dist
				end
			end
		end
	end
	return correLst
end



def calculateDeformSrep(band, tapper, rx, ry, cx, cy, srep)
	# this function takes a srep and information that needed for calculate the deformed srep
	# it returns a deformed s-rep for it
	# srep is a list of sampled medial locus points, and a list of spoke directions and lengths 
	
end 


def parseSavedSrep(filename)
	srepf = File.open(filename, 'r')
	srepst = srepf.gets.strip
	sreps = []
	matches = srepst.scan(/[0-9]+, [0-9]+, [0-9]+\.[0-9]+/)
	matches.each do |m|
		xyr =  m.scan(/[0-9]+/)
		x = xyr[0].to_f
		y = xyr[1].to_f
		r = xyr[2].to_f + xyr[3].to_f/10
		#~ x = x + Math.sqrt(2) * r
		#~ y = y + Math.sqrt(2) * r
		sreps << [[x, y],[[0,0],[0,0],[0,0]], [r,r,r]]
	end
	return sreps
end

def interpolateSkeletalCurveGamma(xt,yt,step_size,index)
# this function takes the discrete base points and interpolate the gamma (skeletal curves)
#   - interpolate gamma can be done using cubic spline 
#   - this function uses system call on a python routine
  # give x, y, stepsize, retrun a interpolated dense points and write it into a file.
  # read that file. 
  # then we have the gamma values. That is for one srep.
  # call the python script to generate intepolated gammas
  xs = '"[' + xt.join(" ") + ']"'
  ys = '"[' + yt.join(" ") + ']"'
  step_size_s = step_size.to_s
  system("python curve_interpolate.py " + xs + ' ' + ys + ' ' + step_size_s+ ' ' + index.to_s)
  # the 'interpolated_points_[index]' file contains interpolated points
  return ixs, iys
end

def interpolateRadius(xt,rt,step_size,index)
# this function interpolates r values
# parameters: x values         xt
#             r values         rt 
#             step size        step_size
  xs = '"[' + xt.join(" ") + ']"'
  rs = '"[' + rt.join(" ") + ']"'
  step_size_s = step_size.to_s
  system("python radius_interpolate.py " + xs + ' ' + rs + ' ' + step_size_s + ' ' + index )
  # the 'interpolated_radius_[index]' file contains interpolated points
  r_file = File.new("interpolated_rs_"+index, "r")
  ixs = r_file.gets
  irs = r_file.gets
  puts "ixs: " + ixs 
  puts "irs: " + irs  
  return irs
end

def interpolateKappa(rt, kt, step_size, index)
# since rk < 1, we need get r to interpolate kappa
# rt is an array that contains radius 
# this function produces the k array that has the same length as the r array
  rk = [rt,kt].transpose.map{|x| x.reduce(:*)}
  puts "inside 1: " + rk.to_s
  rkm1 = rk.collect{|x| 1-x}
  logrkm1 = rkm1.collect{|x| Math.log(x)}
  logrkm1s = '"[' + logrkm1.join(" ") + ']"'
  step_size_s = step_size.to_s
  system("python logrk_interpolate.py " + logrkm1s + ' ' + step_size_s + ' ' + index.to_s)
  # the 'interpolated_logrkm1s' file contains interpolated log(1-rk)
  logrkm1_file = File.new("interpolated_logrkm1s_" + index.to_s , "r")
  ilogrkm1s = logrkm1_file.gets
  puts "ilogrkm1s: " + ilogrkm1s
  return ilogrmk1s
end

def computeBaseKappa(xt,yt, indices, h, rt)
  # this function computes kappas at base points using the curvature formula
  # also checks whether rk at these base points are smaller than 1
  # k = (x'y''-y'x'') / (x'^2+y'^2)^(3/2)
  # compute numerical derivatives 
  # for end points the way to compute derivatives are different
  # the index should not contain the first and the last index
  dx = []
  dy = []
  ddx = []
  ddy = []
  dx0 = (xt[1] - xt[0]) / h
  dx1 = (xt[2] - xt[1]) / h
  dxe = (xt[-1] - xt[-2]) / h
  dxem1 = (xt[-2] - xt[-3]) / h
  ddx0 = (dx1 - dx0) / h
  ddxe = (dxe - dxem1) / h
  dy0 = (yt[1] - yt[0]) / h
  dy1 = (yt[2] - yt[1]) / h
  dye = (yt[-1] - yt[-2]) / h
  dyem1 = (yt[-2] - yt[-3]) / h
  ddy0 = (dy1 - dy0) / h
  ddye = (dye - dyem1) / h
  dx << dx0
  dy << dy0
  ddx << ddx0
  ddy << ddy0
 
  rs = []
  rs << rt[0]
 
  indices.each do |i|
    if i != 0 && i != (xt.length - 1)	
      dxi = ( xt[i+1] - xt[i-1] ) / (2 * h)
      dyi = ( yt[i+1] - yt[i-1] ) / (2 * h)
      ddxi = (xt[i+1] - (2 * xt[i]) + xt[i-1]) / (h**2.0)
      ddyi = (yt[i+1] - (2 * yt[i]) + yt[i-1]) / (h**2.0) 
      dx << dxi 
      dy << dyi 
      ddx << ddxi
      ddy << ddyi
 
      rs << rt[i]
    end
  end

  rs << rt[-1]
  dx << dxe
  dy << dye
  ddx << ddxe
  ddy << ddye
  kappa = []
  kr = []
  
  dx.each_with_index do |dxi, i|
    ki = (dx[i] * ddy[i] - dy[i] * ddx[i]) / ((dx[i]**2)+(dy[i]**2))**(3.0/2.0) 
    kappa << ki
    #compute k * r 
    kri = ki * rs[i]
    kr << kri
  end
 
  return kappa, kr 
end

def interpolateSpokeAtPosition(t,ut,kt,at,pos)
# 
end

def generateBentSrep()
# work on it later
end


