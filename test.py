import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
    
x = []
y = []
points = [[50,100],[100,75],[150,50],[200,60],[250,80]]
for p in points:
	x.append(p[0])
	y.append(p[1])

s = interpolate.InterpolatedUnivariateSpline(x,y)
xnew = np.arange(50,250,1)
ynew = s(xnew)

plt.figure()
plt.plot(x,y,'x',xnew,ynew)

plt.axis('equal')
plt.show()


