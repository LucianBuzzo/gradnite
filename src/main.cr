require "./Node"
require "./Neuron"
require "./draw"

puts "\n\n============ Running ============\n"

x = [2.0, 3.0, -1.0]
n = MLP.new(3, [4, 4, 1])

xs = [
  [2.0, 3.0, -1.0],
  [3.0, -1.0, 0.5],
  [0.5, 1.0, 1.0],
  [1.0, 1.0, -1.0],
]
ys = [
  1.0, -1.0, -1.0, 1.0,
]

ypred = [] of Node
loss = Node.new(0.0)

100.times do |k|
  # forward pass
  ypred = xs.map { |x|
    n.forward(x)
  }

  loss = ypred.map_with_index { |y, i|
    (y[0] - ys[i]) ** 2.0
  }.sum

  puts "loss #{k}: #{loss.value}"

  # backward pass
  n.parameters.each { |p|
    # Zero grad!
    p.grad = 0.0
  }
  loss.backward

  # Gradient descent. Nudge all the parameters in the opposite direction of the gradient.
  # The gradient is showing us the direction that increases the loss, so we want to go the opposite way.
  n.parameters.each { |p|
    p.value += -0.1 * p.grad
  }
end

dot_str = draw_dot(loss)

puts ypred.map { |y| y.is_a?(Node) ? y.value : y[0].value }

puts "done"

# Write the output to 'tree.dot'
File.write("tree.dot", dot_str)
