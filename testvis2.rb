require 'rubyvis'
load 'ellip_factory.rb'

	
p = EllipFactory.calculatePointsOnBoundary(128, 20, 15, 64, 64)
#puts p
newP = EllipFactory.deformEllip(p, 3.0, 0)
p = newP
puts newP
data = pv.range(p.size).map {|i| 
  OpenStruct.new({x: p[i][0], y: p[i][1], z: 1})
}


w = 400	
h = 400

x = pv.Scale.linear(0, 128).range(0, w)
y = pv.Scale.linear(0, 128).range(0, h)

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

f = File.open('test.html', 'w')
f.puts vis.to_svg
