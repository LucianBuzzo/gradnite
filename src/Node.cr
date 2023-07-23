def topo_sort(v : Node, topo, visited)
  unless visited.includes?(v)
    visited.add(v)
    v._prev.each do |child|
      topo_sort(child, topo, visited)
    end
    topo << v
  end
end

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

  def initialize(@value : Float64, @_children = [] of Node, @_op = "", @label = "")
    @_prev = @_children
    @_backward = ->{ nil }
    @id = "n#{(@@id_counter += 1)}"
    @grad = 0.0
  end

  def +(other : Node | Float64)
    if other.is_a?(Float64)
      other = Node.new(other)
    end
    out = Node.new(@value + other.value, [self, other], "+")

    out._backward = ->{
      self.grad += 1.0 * out.grad
      other.grad += 1.0 * out.grad
    }

    out
  end

  def -(other : Node | Float64)
    if other.is_a?(Float64)
      other = Node.new(other)
    end
    self + (other * -1.0)
  end

  def *(other : Node | Float64)
    if other.is_a?(Float64)
      other = Node.new(other)
    end
    out = Node.new(@value * other.value, [self, other], "*")

    out._backward = ->{
      self.grad += other.value * out.grad
      other.grad += self.value * out.grad
    }

    out
  end

  def **(other : Int64 | Float64)
    out = Node.new(self.value ** other, [self], "**#{other}")

    out._backward = ->{
      self.grad += other * (self.value ** (other - 1.0)) * out.grad
    }

    out
  end

  def /(other : Node)
    self * other**-1.0
  end

  def tanh
    t = Math.tanh(@value)
    n = Node.new(t, [self], "tanh")

    n._backward = ->{
      self.grad += (1.0 - t * t) * n.grad
    }

    n
  end

  def exp
    x = self.value
    out = Node.new(Math.exp(x), [self], "exp")

    out._backward = ->{
      self.grad += out.value * out.grad
    }

    out
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

  def self.zero : Node
    Node.new(0.0)
  end
end
