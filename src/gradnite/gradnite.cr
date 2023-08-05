require "./draw"
require "./tensor/tensor"

module Gradnite
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

  class Neuron
    property weights : Array(Node)
    property bias : Node

    def initialize(input_count : Int64)
      @weights = Array.new(input_count) { Node.new(0.01 * rand) }
      @bias = Node.new(0.0)
    end

    def run(x : Array(Float64) | Array(Node))
      act = x.zip(@weights).map { |x, w| w * x }.sum + @bias
      out = act.tanh
      out
    end

    def parameters
      @weights + [@bias]
    end
  end

  class Layer
    property neurons : Array(Neuron)

    def initialize(input_count : Int64, neuron_count : Int64)
      @neurons = Array.new(neuron_count) { Neuron.new(input_count) }
    end

    def run(x : Array(Float64) | Array(Node))
      out = @neurons.map { |n| n.run(x) }
      out
    end

    def parameters
      @neurons.flat_map { |n| n.parameters }
    end
  end

  class MLP
    property layers : Array(Layer)

    def initialize(input_count : Int32, layer_sizes : Array(Int32))
      sz = [input_count] + layer_sizes
      puts sz
      @layers = layer_sizes.map_with_index do |size, i|
        Layer.new(sz[i], sz[i + 1])
      end
    end

    def forward(x : Array(Float64))
      @layers.each { |l|
        x = l.run(x)
      }

      # Cast all values to Node class
      x = x.map { |x| x.is_a?(Float64) ? Node.new(x) : x }
    end

    def parameters
      @layers.flat_map { |l| l.parameters }
    end

    def to_s
      @layers.map_with_index { |l, i|
        "Layer #{i}:\n" + l.neurons.map_with_index { |n, j|
          "  Neuron #{j}:\n" + n.weights.map_with_index { |w, k|
            "    Weight #{k}: #{w}"
          }.join("\n") + "\n    Bias: #{n.bias}"
        }.join("\n")
      }.join("\n")
    end
  end
end
