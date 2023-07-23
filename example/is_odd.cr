require "../src/gradnite/gradnite"

include Gradnite

# BIT_SIZE is our input layer size
BIT_SIZE = 8

# Layer size is approximately 2/3 of the input size
LAYER_SIZE = (BIT_SIZE * 2/3).ceil.to_i

mlp = MLP.new(BIT_SIZE, [LAYER_SIZE, LAYER_SIZE, 1])

max = 255
nums = (1..max).to_a

def num_to_binary_array(n)
  BIT_SIZE.times.map { |bit|
    ((n >> bit) & 1) == 1 ? 1.0 : -1.0
  }.to_a
end

# Normalize the inputs to be a binary number represented as an array of -1.0 and 1.0
training_inputs = nums.map { |n|
  num_to_binary_array(n)
}

training_outputs = nums.map { |n| n.even? ? -1.0 : 1.0 }

ypred = [] of Node

loss = Node.new(0.0)

epochs = 100

epochs.times do |k|
  # forward pass
  ypred = training_inputs.map { |x|
    mlp.forward(x)
  }

  loss = ypred.map_with_index { |y, i|
    (y[0] - training_outputs[i]) ** 2.0
  }.sum

  # backward pass
  mlp.parameters.each { |p|
    # Zero grad!
    p.grad = 0.0
  }
  loss.backward

  # Gradient descent. Nudge all the parameters in the opposite direction of the gradient.
  # The gradient is showing us the direction that increases the loss, so we want to go the opposite way.
  # Linear decay of learning rate
  learning_rate = (epochs - k.to_f) / epochs * 0.1
  mlp.parameters.each { |p|
    p.value += -learning_rate * p.grad
  }
end

puts "loss: #{loss.value}"
# puts ypred.map { |y| y.is_a?(Node) ? y.value : y[0].value }

puts "testing"

def is_odd?(n, mlp)
  result = mlp.forward(num_to_binary_array(n))[0].value
  return result > 0.0
end

puts is_odd?(201, mlp)
puts is_odd?(202, mlp)
puts is_odd?(203, mlp)

puts "done"
