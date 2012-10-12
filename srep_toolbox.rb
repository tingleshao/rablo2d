
$pi = Math::PI

def generate2DDiscreteSrep(rx,ry,cx,cy,size)
	mr = (rx**2 + ry**2).to_f / rx
	# hand code the u's 
	m = []
	angle = [$pi*2/3, $pi*11/18, $pi*5/9, $pi/2, $pi*4/9, $pi*7/18, $pi/3]
	for i in -3..3
		a = []
		# calculate p
		step = mr/3
		p = [cx-step*i, cy]
		# calculate u0, u1, u2
		sx = Math.cos(angle[i+3])
		sy = Math.sin(angle[i+3])
		u0 = [sx, sy]
		u1 = [sx, -1*sy]
		if i == 3 then u2 = [1,0] else u2 = [-1,0] end
		u = [u0, u1, u2]
		# calculate r0, r1, r2
		# now don't calculate, just set they all the same.
		r_same = (rx - mr ) *2
		r0 = r1 = r_same* 1.1 *  Math.log(6.4 - i.abs)
		#~ r0 = r1 = r_same
		if i == -3 then r2  = r_same  elsif i == 3 then r2 = r_same else r2 = 0 end
		r = [r0, r1, r2]
		a = [p, u, r]
		m << a
	end
	return m
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
