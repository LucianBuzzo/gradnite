<div align="center">

![Gradnite](assets/gradnite-banner-light.png#gh-light-mode-only)
![Gradnite](assets/gradnite-banner-dark.png#gh-dark-mode-only)

<p>
    <strong>A simple Autograd engine written in Crystal.</strong
</p>

</div>

## Usage

Add Gradnite to your `shard.yml` and run `shards install`:

```yaml
dependencies:
  gradnite:
    github: lucianbuzzo/gradnite
    version: 0.1.0
```

You can now require the module and use it's classes:

```crystal
# require the gradnite module
require "gradnite"

# create a new Node
node = Gradnite::Node.new(1.0)

# add two nodes together
node = Gradnite::Node.new(1.0) + Gradnite::Node.new(2.0)

# multiply two nodes together
node = Gradnite::Node.new(1.0) * Gradnite::Node.new(2.0)

# divide two nodes together
node = Gradnite::Node.new(1.0) / Gradnite::Node.new(2.0)

# create a Neuron with 4 inputes
neuron = Gradnite::Neuron.new(4)

# create an MLP with 2 inputs, 2 hidden layers of 3 neurons each and 1 output
mlp = Gradnite::MLP.new(2, [3, 3, 1])

# run a forward pass on the mlp
mlp.forward([1.0, 2.0])

# run back propagation on the mlp
mlp.backward

# update the weights of the mlp
mlp.parameters.each { |p|
    p.value += -0.1 * p.grad
}
```

Gradnite also includes a utility for visualizing the computation graph of a neural network using `graphviz`. To use it, make sure you have `graphviz` installed locally and call the `draw_dot` function with a node:

```crystal
a = Gradnite::Node.new value: 1.0, label: "a"
b = Gradnite::Node.new value: 2.0, label: "b"
c = a * b
c.label = "c"

Gradnite::draw_dot(c, "examples/multiply.dot")
```

You can now generate a png image of the computation graph using the `dot` command:

```bash
dot -Tpng examples/multiply.dot -o examples/multiply.png
```

For more examples of usage see the [examples](examples) directory.

## Development

Install prerequisites:

```bash
brew install crystal watchexec graphviz
```

Run in watch mode:

```bash
./watch.sh examples/binary_classifier.cr
```
