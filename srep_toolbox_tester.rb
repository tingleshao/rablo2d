load 'srep_toolbox.rb'
def ddl
srep1= generateStraight2DDiscreteSrep(20,15,64,64,128,3);
#~ srep2 = generate2DDiscreteSrep(20,15,32,32,128);
#~ $corrLes = checkSrepIntersection(srep1, srep2, 0,0);
return srep1
end
srep = ddl 
#~ puts $corrLes
puts srep.to_s