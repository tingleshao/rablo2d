load 'ellip_factory.rb'
	
p = EllipFactory.calculatePointsOnBoundary(128, 20, 15, 64, 64)
#puts p
newP = EllipFactory.deformEllip(p, 1.2, 0.0)
p = newP

def point(x, y, color, bg_color)
	stroke color
	line x, y, x, y+1
	stroke bg_color
	line x, y+1, x+1, y+1
end


def point_big(x, y, color, bg_color)
	stroke color
	strokewidth 1
	fill black
	oval x,y, 3.5
end

Shoes.app :width => 256, :height => 256, :resizable => false do 
	background white
	p.collect { |po| point_big  2 * po[0],  256 - 2 * po[1], blue, white}
end