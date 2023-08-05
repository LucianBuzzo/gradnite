class Tensor(T)
  property value : T

  def initialize(@value : T)
  end

  def self.full(shape : Array(Int32), value : Float64)
    if (shape.size == 1)
      return Tensor.new(Array(Float64).new(shape[0], value))
    end

    if (shape.size == 2)
      v = (
        Array(Float64).new(
          shape[0], 0
        ).map {
          Array(Float64).new(shape[1], value)
        }
      )
      return Tensor.new(v)
    end

    if (shape.size == 3)
      return Tensor.new(
        Array(Float64).new(
          shape[0], 0
        ).map {
          Array(Float64).new(
            shape[1], 0
          ).map {
            Array(Float64).new(shape[2], value)
          }
        }
      )
    end

    raise "Dimensions higher than 3 are not implemented"
  end

  def self.zeros(shape : Array(Int32))
    self.full(shape, 0.0)
  end

  def self.ones(shape : Array(Int32))
    self.full(shape, 1.0)
  end

  def size : Array(Int32)
    s = [] of Int32
    n = @value
    if (n.is_a?(Array))
      s << n.size
      n = n[0]
      if (n.is_a?(Array))
        s << n.size
        n = n[0]
        if (n.is_a?(Array))
          s << n.size
        end
      end
    end

    s
  end

  # Matrix multiplication
  def matmul(other : Tensor(T))
    if (self.size.size != 2 || other.size.size != 2)
      raise "Can only multiply 2d matrices"
    end

    if (self.size[1] != other.size[0])
      raise "Matrix dimensions cannot be multiplied, #{self.size} and #{other.size}"
    end

    result = Array(Float64).new(self.size[0], 0).map {
      Array(Float64).new(other.size[1], 0)
    }

    self.size[0].times do |i|
      other.size[1].times do |j|
        self.size[1].times do |k|
          result[i][j] += @value[i][k] * other.value[k][j]
        end
      end
    end

    Tensor.new(result)
  end

  def to_s(io : IO)
    s = @value
    if (@value.is_a?(Array))
      s = s.map { |x| x.to_s }.join(",\n" + " " * 7)
    end
    io << "Tensor(#{s})"
  end
end
