import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
import sys
# the passed x and r data array should be quoted 
# the step size should be the relative size in [0 1]
# btw: it is good to use step_size=0.01...

def writeRadius(x,r,f):
	for xp in x:
		f.write(str(xp))
		f.write(" ")
	f.write('\n')
	for rp in r:
		f.write(str(rp))
		f.write(" ")


xs = sys.argv[1]
rs = sys.argv[2]
step_size = float(sys.argv[3])
xx = xs.strip('[]').split(' ')
rr = rs.strip('[]').split(' ')
x = []
r = []
# convert string to array
for xp in xx:
	x.append(int(xp))
for rp in rr:
	r.append(int(rp))

print x
print r

t = np.arange(0.0,1.2,0.2)
tck,u = interpolate.splprep([x,r],s=0)
unew = np.arange(0.0,1.01,step_size)
out = interpolate.splev(unew,tck)
print out

#f = open('interpolated_rs','w')
#writePts(unew, ynew,f)

plt.figure()
plt.plot(x,r,'x',out[0],out[1])
plt.axis('equal')
#
plt.show()