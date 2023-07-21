def draw_dot(root : Node) : String
  dot = "digraph {\n"
  dot += "rankdir=LR;\n"

  nodes, edges = trace(root)
  nodes.each do |n|
    uid = n.id.to_s
    dot += "#{uid} [label=\"{ #{n.value} }\", shape=record];\n"
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
  property value
  property _children
  property _prev
  property _op

  def initialize(@value : Float32, @_children = [] of Node, @_op = "")
    @_prev = @_children
    @id = "n#{(@@id_counter += 1)}"
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

def trace(root : Node) : Tuple(Set(Node), Set(Tuple(Node, Node)))
  nodes, edges = Set(Node).new, Set(Tuple(Node, Node)).new

  build(root, nodes, edges)

  {nodes, edges}
end

a = Node.new 2.0
b = Node.new -3.0
c = Node.new 10.0

d = a * b + c

puts d

puts d._op

dot_str = draw_dot(d)

# Write the output to 'tree.dot'
File.write("tree.dot", dot_str)
