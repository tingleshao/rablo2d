require 'gnuplot'
load 'ellip_factory.rb'

Gnuplot.open { |gp|
    Gnuplot::Plot.new( gp ) { |plot|
 
        plot.title  "Ellipsoid"
        plot.ylabel "x"
        plot.xlabel "y"
	
	p = EllipFactory.calculatePointsOnBoundary(128, 20, 15, 64, 64)
	
	s = p.size
	x = (0..size-1).collect {|v| p[v][0] }
	y = (0..size-1).collect {|v| p[v][1] }
	
        plot.data << Gnuplot::DataSet.new( [x, y] ) { |ds|
            ds.with = "linespoints"
            ds.notitle
        }
    }
}
