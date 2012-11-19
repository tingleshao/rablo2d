load 'srep_toolbox.rb'
load 'atom.rb'
load 'srep.rb'
def ddl
srep1= generateStraight2DDiscreteSrep(20,15,64,64,128,3);
#~ srep2 = generate2DDiscreteSrep(20,15,32,32,128);
#~ $corrLes = checkSrepIntersection(srep1, srep2, 0,0);
return srep1
end

def ddl2
	srep1 = generateStraight2DDiscreteSrepC();
	return srep1
end

def ddl3
  points = [[10,20],[20,15],[30,10],[40,12],[50,16]]
  l = [[7,7,7],[7,7],[7,7],[8,8],[7,7,7]]
  u = [[[-1,3],[-1,-4],[-3,-1]],[[-1,4],[-1,-5]],[[-1,4],[-1,-6]],[[1,9],[1,-8]],[[1,2],[1,-5],[3,2]]]
  srep = generate2DDiscreteSrep(points,l,u)
  puts 'ddl'
  puts srep
end

def ddl4
  points = [[10,20],[20,15],[30,10],[40,12],[50,16]]
  x = points.collect{|p| p[0]}

  y = points.collect{|p| p[1]}
#  puts "y: " + y.to_s
  interpolateSkeletalCurveGamma(x,y,1)
end

def ddl5

end


ddl4
