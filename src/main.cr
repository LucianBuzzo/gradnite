def trace(root : Node) : Tuple(Set(Node), Set(Tuple(Node, Node)))
  nodes, edges = Set(Node).new, Set(Tuple(Node, Node)).new

  build(root, nodes, edges)

  {nodes, edges}
end

def draw_dot(root : Node) : String
  dot = "digraph {\n"
  dot += "rankdir=LR;\n"

  nodes, edges = trace(root)
  nodes.each do |n|
    uid = n.id.to_s
    dot += "#{uid} [label=\"{ #{n.label} | data #{n.value} | grad #{n.grad} }\", shape=record];\n"
    if n._op != ""
      opLabel = n._op === "+" ? "plus" : "mul"
      dot += "#{uid + opLabel} [label=\"#{n._op}\"];\n"
      dot += "#{uid + opLabel} -> #{uid};\n"
    end
  end

  edges.each do |n1, n2|
    opLabel = n2._op === "+" ? "plus" : "mul"
    dot += "#{n1.id.to_s} -> #{n2.id.to_s + opLabel};\n"
  end

  dot += "}\n"

  dot
end

puts "\n\n============ Running ============\n"

struct Node
  @@id_counter = 0

  property id : String
  property label : String
  property value
  property grad
  property _children
  property _prev
  property _op

  def initialize(@value : Float32, @_children = [] of Node, @_op = "", @label = "")
    @_prev = @_children
    @id = "n#{(@@id_counter += 1)}"
    @grad = 0.0
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

def build(v : Node, nodes, edges)
  unless nodes.includes?(v)
    nodes.add(v)
    v._prev.each do |child|
      edges.add({child, v})
      build(child, nodes, edges)
    end
  end
end

a = Node.new value: 2.0, label: "a"
b = Node.new -3.0, label: "b"
c = Node.new 10.0, label: "c"
e = a * b
e.label = "e"

d = e + c
d.label = "d"

f = Node.new -2.0, label: "f"

l = d * f
l.label = "L"

puts d

dot_str = draw_dot(l)

# Write the output to 'tree.dot'
File.write("tree.dot", dot_str)
