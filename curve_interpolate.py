import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
import sys



def writePts(x,y,f):
	for xp in x:
		f.write(str(xp))
		f.write(" ")
	f.write('\n')
	for yp in y:
		f.write(str(yp))
		f.write(" ")




# the passed x and y data should be quoted 
xs = sys.argv[1]
ys = sys.argv[2]
step_size = int(sys.argv[3])
xx = xs.strip('[]').split(' ')
yy = ys.strip('[]').split(' ')
x = []
y = []
# convert string to array
for xp in xx:
	x.append(int(xp))
for yp in yy:
	y.append(int(yp))



#points = [[50,100],[100,75],[150,50],[200,60],[250,80]]
#for p in points:
#	x.append(p[0])
#	y.append(p[1])

s = interpolate.InterpolatedUnivariateSpline(x,y)
xnew = np.arange(x[0],x[-1],step_size)
ynew = s(xnew)

f = open('interpolated_points','w')
writePts(xnew, ynew,f)


#plt.figure()
#plt.plot(x,y,'x',xnew,ynew)

#plt.axis('equal')
#plt.show()
