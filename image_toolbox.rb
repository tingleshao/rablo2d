# this is a library that contains many useful functions for processing images 
# 	that needed for 2D multi-object display software.
# 
# Author: Chong Shao (cshao@cs.unc.edu)
# 

require 'rubyvis'


$pi = Math::PI

def generateBinary(size, rx, ry, cx, cy, bend, tapper)
	# this function takes all information it needs to generate a binary image. 
	# the binary image format is a 2d array. contains 0 or 1
	image = ""
	for x in 0..size - 1
		for y in 0..size - 1
			# here the row & col value is the actrual x and y.
			# use the actrual x and y to calculate the x and y before deformatoin
			# and use that to check the ellipsoid formula
			# set inside 1, out side 0
			normX = ( x - cx ).to_f / size
			normY = ( y - cy ).to_f / size
			ox = normX
			oy = ( normY - ( bend * normX )**2 ) / (Math::exp(tapper * normX))
			realX = ( ox * size ) + cx 
			realY = ( oy * size ) + cy
			# check whether realX and realY is inside or outside of the ellipsoid
			if  ( ( realX - cx ) / rx )**2  + ( ( realY - cy ) / ry )**2 > 1 #=> outside of the ellipsoid
				image += "0"
			else
				image += "1"
			end
		end
	end
	return image
end

def binaryToPointList(bin, size)
	# this function converts binary image to point list 
	pointLst = []
	for x in 0..size-1
		for y in 0..size-1
			index  = x * size + y 
			if bin[index] == '1'
				pointLst << [x, y]
			end
		end
	end
	return pointLst
end

def pointListToBinary(ptLst, size)
	# this function is the inverse operation of binaryToPointList()
	bin = ''
	copyPtLst = Array.new(ptLst)
	for x in 0..size-1
		for y in 0..size-1
			if copyPtLst.include?([x,y])
				bin << "1"
			else
				bin << "0"
			end
			copyPtLst.delete([x,y])
		end
	end
	return bin
end

def binaryToBinaryMatrix(bin, size)
	# i think doing dialation on point list will be slow. so it is necessary to make a new
	# 	represenation which is binary matrix
	binMat = []
	for x in 0..size-1
		row = []
		for y in 0..size-1
			index = x * size + y
			if bin[index] == "1"
				row << 1
			else 
				row << 0
			end
		end
		binMat << row
	end
	return binMat
end

def binaryMatrixToBinary(binmat, size)
	# this is the inverse transform to binaryToBinaryMatrix() function
	bin = ""
	for x in 0..size-1
		for y in 0..size-1
			if binmat[x][y] == 1
				bin << "1"
			else 
				bin << "0"
			end
		end
	end
	return bin
end

# => may later somehow combine these following two methods by number of parameters
def displayBinary(bin, size, filename)
	# this function outputs the html file to current directory, which contains SVG for the binary 
	p = binaryToPointList(bin, size)
	data = pv.range(p.size).map {|i| 
	  OpenStruct.new({x: p[i][0], y: p[i][1], z: 1})
	}
	
	w = 400	
	h = 400

	x = pv.Scale.linear(0, size).range(0, w)
	y = pv.Scale.linear(0, size).range(0, h)

	c = pv.Scale.log(1, 100).range("orange", "brown")

	# The root panel.
	vis = pv.Panel.new()
	    .width(w)
	    .height(h)
	    .bottom(20)
	    .left(20)
	    .right(10)
	    .top(5);

	# Y-axis and ticks. 
	vis.add(pv.Rule)
	    .data(y.ticks())
	    .bottom(y)
	    .strokeStyle(lambda {|d| d!=0 ? "#eee" : "#000"})
	  .anchor("left").add(pv.Label)
	  .visible(lambda {|d|  d > 0 and d < 128})
	  .text(y.tick_format)

	# X-axis and ticks. 
	vis.add(pv.Rule)
	    .data(x.ticks())
	    .left(x)
	    .stroke_style(lambda {|d| d!=0 ? "#eee" : "#000"})
	  .anchor("bottom").add(pv.Label)
	  .visible(lambda {|d|  d > 0 and d < 128})
	  .text(x.tick_format);

	#/* The dot plot! */
	vis.add(pv.Panel)
	    .data(data)
	  .add(pv.Dot)
	  .left(lambda {|d| x.scale(d.x)})
	  .bottom(lambda {|d| y.scale(d.y)})
	  .stroke_style(lambda {|d| c.scale(d.z)})
	  .fill_style(lambda {|d| c.scale(d.z).alpha(0.2)})
	  .shape_size(lambda {|d| d.z})
	  .title(lambda {|d| "%0.1f" % d.z})

	vis.render()

	f = File.open(filename+'.html', 'w')
	f.puts vis.to_svg
end

def displayBinaryWithSrep(bin, size, srep, filename)
	# this function generates a html file that contains svg. The html displays the ellipsoid with the srep.
	# parameters: image in binary format, size of the image,  center of the ellipsoid, the output filename and the srep points list.
	p = binaryToPointList(bin, size)
	data = pv.range(p.size).map {|i| 
	  OpenStruct.new({x: p[i][0], y: p[i][1], z: 1})
	}
	
	sdata = pv.range(srep.size).map {|i| 
	  OpenStruct.new({x: srep[i][0][0], y: srep[i][0][1], z: 90})
	}
	
	w = 400	
	h = 400

	x = pv.Scale.linear(0, size).range(0, w)
	y = pv.Scale.linear(0, size).range(0, h)

	c = pv.Scale.log(1, 100).range("orange", "brown")

	# The root panel.
	vis = pv.Panel.new()
	    .width(w)
	    .height(h)
	    .bottom(20)
	    .left(20)
	    .right(10)
	    .top(5);

	# Y-axis and ticks. 
	vis.add(pv.Rule)
	    .data(y.ticks())
	    .bottom(y)
	    .strokeStyle(lambda {|d| d!=0 ? "#eee" : "#000"})
	  .anchor("left").add(pv.Label)
	  .visible(lambda {|d|  d > 0 and d < 128})
	  .text(y.tick_format)

	# X-axis and ticks. 
	vis.add(pv.Rule)
	    .data(x.ticks())
	    .left(x)
	    .stroke_style(lambda {|d| d!=0 ? "#eee" : "#000"})
	  .anchor("bottom").add(pv.Label)
	  .visible(lambda {|d|  d > 0 and d < 128})
	  .text(x.tick_format);

	#/* The dot plot! */
	vis.add(pv.Panel)
	    .data(data)
	  .add(pv.Dot)
	  .left(lambda {|d| x.scale(d.x)})
	  .bottom(lambda {|d| y.scale(d.y)})
	  .stroke_style(lambda {|d| c.scale(d.z)})
	  .fill_style(lambda {|d| c.scale(d.z).alpha(0.2)})
	  .shape_size(lambda {|d| d.z})
	  .title(lambda {|d| "%0.1f" % d.z})

	# s-rep plot
	vis.add(pv.Panel)
	    .data(sdata)
	  .add(pv.Dot)
	  .left(lambda {|d| x.scale(d.x)})
	  .bottom(lambda {|d| y.scale(d.y)})
	  .stroke_style(lambda {|d| c.scale(1)})
	  .fill_style(lambda {|d| c.scale(d.z).alpha(1)})
	  .shape_size(lambda {|d| 10})
	  .title(lambda {|d| "%0.1f" % d.z})
	vis.render()

	f = File.open(filename+'.html', 'w')
	f.puts vis.to_svg
end

def dilateBinary(bin, size, opSize)
	# this function dilates the given binary image. with the DISK operator size indicated by opSize.
	# may be dilation is easier written in matlab......
	# it returns a dilated binary image
	# firstly convert the binary to point list.
	# dilation on list
	# then convert back
	# it turns out that, speed is not so bad in 128 * 128
	binMat = binaryToBinaryMatrix(bin, size)
	# NOTE: the array returned by local method may just be an address.
	# 	Which makes dup() and clone() not work in this case.
	dilBinMat = []
	size.times do 
		dilRow = []
		size.times do 
			dilRow << 0
		end
		dilBinMat << dilRow
	end # ==> initialize dialBinMat
	for x in 0..size-1
		for y in 0..size-1
			if binMat[x][y] == 1
			#	puts "x: " + x.to_s + " y: " + y.to_s
				# here is inverted :P , x is row, y is column
				
				# this two lines give the operation row range.
				if x-opSize > -1
					xLow = x - opSize
				else 
					xLow = 0
				end
				if x+opSize < size
					xHigh = x + opSize
				else
					xHigh = size - 1
				end
				for dilRow in xLow..xHigh
					yCalcLow = (y - Math.sqrt(opSize**2-(dilRow-x)**2)).floor
					yCalcHigh = (y + Math.sqrt(opSize**2-(dilRow-x)**2)).ceil
					if yCalcLow > -1
						yLow = yCalcLow
					else 
						yLow = 0
					end
					if yCalcHigh < size
						yHigh = yCalcHigh
					else
						yHigh = size - 1
					end
					for dilCol in yLow..yHigh
						dilBinMat[dilRow][dilCol] = 1
					end
					# puts "yLow " + yLow.to_s + " yHigh: " + yHigh.to_s + " dialRow size: " + dialRow.size.to_s
				end
			end
		end
	end
	#  convert binmat to bin, return bin
	dilBin = binaryMatrixToBinary(dilBinMat, size)
	return dilBin
end

def generateStandardSrep(binary, nAtoms, size, rx, ry, cx, cy)
	# this function takes a binary ellipsoid image, it should be a standard one
	# it returns a standard s-rep for it
	# srep is a list of 
		# sampled medial locus points: p
		# spoke directions: u
		# lengths: r
	# suggest number of atoms in 128 * 128 image 20 * 15 ellip: 9
	# how to calculate the standard s-rep? 
		# i need to look at wenqi's c++ code
	# for now, just make an approximate s-rep and use it for display program
	srep = []
	# set the two end point r_mid to be 1/2 ry
	r_mid = 1.0/3 * ry 
	# set the central point pos 
	p = []
	9.times do 
		p << 0
	end
	p[4] = [cx, cy]
	cx0 = cx - rx + r_mid
	p[0] = [cx0, cy]
	medialLength = 2 * (rx - r_mid)
	stepSize = medialLength.to_f / 9
	puts "step size: " + stepSize.to_s
	8.times do |i|
		p[i+1] = [cx0 + stepSize * (i+1), cy]
	end		
	# array for spoke ends diretions 
	u = []
	9.times do 
		u << 0
	end
	leftEndUpperAngle = 2 * $pi / 3
	leftEndLowerAngle = -2 * $pi / 3 
	u[0] = [leftEndUpperAngle, leftEndLowerAngle, $pi]
	angleStepSize = $pi / 24
	8.times do |i|
		u[i+1] = [leftEndUpperAngle - angleStepSize, leftEndLowerAngle + angleStepSize , $pi]
	end
	# array for spoke length
		# for now, i have not derive the spoke length formula, so we assume the spoke length are all the same.
	r = []
	9.times do 
		one_r = []
		3.times do
			one_r << r_mid
		end
		r << one_r
	end
	
	9.times do |i|
		srep << [p[i], u[i], r[i]]
	end
	return srep
end


def calculateDeformSrep(band, tapper, rx, ry, cx, cy, srep)
	# this function takes a srep and information that needed for calculate the deformed srep
	# it returns a deformed s-rep for it
	# srep is a list of sampled medial locus points, and a list of spoke directions and lengths 
end 
	