class Neuron
  property weights : Array(Node)
  property bias : Node

  def initialize(input_count : Int64)
    @weights = Array.new(input_count) { Node.new(rand) }
    @bias = Node.new(rand)
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
