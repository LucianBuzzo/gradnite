struct Node
  property value

  def initialize(@value : Float32)
  end

  def +(other : Node)
    Node.new(@value + other.value)
  end

  def *(other : Node)
    Node.new(@value * other.value)
  end
end

a = Node.new 2.0
b = Node.new -3.0
c = Node.new 10.0

e = a * b
d = e + c
f = Node.new(-2.0)
l = d * f

puts a.value
puts b.value
puts c.value
puts e.value
puts d.value
puts f.value
puts l.value
