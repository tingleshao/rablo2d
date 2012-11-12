load 'image_toolbox.rb'


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

def generateBentSrep()
	# work on it later
end


