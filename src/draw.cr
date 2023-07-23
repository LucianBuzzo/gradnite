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
