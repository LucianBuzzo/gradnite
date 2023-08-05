require "../src/gradnite/gradnite"

a = Tensor.new([[1, 2], [3, 4]])
b = Tensor.new([[2, 0], [1, 2]])
c = a.matmul(b)
puts c

a = Tensor.new([
  [1, 2, 3],
  [4, 5, 6],
])
b = Tensor.new([
  [7, 8],
  [9, 10],
  [11, 12],
])
c = a.matmul(b)
puts c
