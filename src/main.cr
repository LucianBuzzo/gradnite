struct Node
  property value
  property _children
  property _prev
  property _op

  def initialize(@value : Float32, @_children = [] of Node, @_op = "")
    @_prev = @_children
  end

  def +(other : Node)
    Node.new(@value + other.value, [self, other], "+")
  end

  def *(other : Node)
    Node.new(@value * other.value, [self, other], "*")
  end

  def to_s(io : IO)
    io << "value=#{@value.to_s}"
  end
end

def to_dot(node : Node, file : IO)
  node._children.each do |child|
    file.puts "\"#{node._op} #{node.value}\" -> \"#{child._op} #{child.value}\";"
    to_dot(child, file)
  end
end

puts "\n\n============ Running ============\n"

a = Node.new 2.0
b = Node.new -3.0
c = Node.new 10.0

d = a * b + c

puts d

puts d._op

File.open("tree.dot", "w") do |file|
  file.puts "digraph Tree {"
  to_dot(d, file)
  file.puts "}"
end
