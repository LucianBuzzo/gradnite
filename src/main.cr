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
    dot += "#{uid} [label=\"{ #{n.label} | data #{sprintf("%.4f", n.value)} | grad #{sprintf("%.4f", n.grad)} }\", shape=record];\n"
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

def topo_sort(v : Node, topo, visited)
  unless visited.includes?(v)
    visited.add(v)
    v._prev.each do |child|
      topo_sort(child, topo, visited)
    end
    topo << v
  end
end

puts "\n\n============ Running ============\n"

class Node
  @@id_counter = 0

  property id : String
  property label : String
  property value
  property grad
  property _children
  property _prev
  property _op
  property _backward : Proc(Nil)

  def initialize(@value : Float32, @_children = [] of Node, @_op = "", @label = "")
    @_prev = @_children
    @_backward = ->{ nil }
    @id = "n#{(@@id_counter += 1)}"
    @grad = 0.0
  end

  def +(other : Node)
    out = Node.new(@value + other.value, [self, other], "+")

    out._backward = ->{
      self.grad = 1.0 * out.grad
      other.grad = 1.0 * out.grad
    }

    out
  end

  def *(other : Node)
    out = Node.new(@value * other.value, [self, other], "*")

    out._backward = ->{
      self.grad = other.value * out.grad
      other.grad = self.value * out.grad
    }

    out
  end

  def tanh
    t = Math.tanh(@value)
    n = Node.new(t, [self], "tanh")

    n._backward = ->{
      self.grad = (1.0 - t * t) * n.grad
    }

    n
  end

  def backward
    topo = [] of Node
    visited = Set(Node).new

    topo_sort(self, topo, visited)

    self.grad = 1.0

    reverse_topo = topo.reverse

    reverse_topo.each do |n|
      n._backward.call
    end
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

# inputs x1 and x2
x1 = Node.new 2.0, label: "x1"
x2 = Node.new 0.0, label: "x2"
# weights w1 and w2
w1 = Node.new -3.0, label: "w1"
w2 = Node.new 1.0, label: "w2"
# bias of neuron
b = Node.new 6.881373, label: "b"
# x1*w1 + x2*w2 + b
x1w1 = x1 * w1
x1w1.label = "x1w1"
x2w2 = x2 * w2
x2w2.label = "x2w2"
x1w1x2w2 = x1w1 + x2w2
x1w1x2w2.label = "x1w1x2w2"
n = x1w1x2w2 + b
n.label = "n"

o = n.tanh
o.label = "o"

o.backward

dot_str = draw_dot(o)

puts "done"

# Write the output to 'tree.dot'
File.write("tree.dot", dot_str)
