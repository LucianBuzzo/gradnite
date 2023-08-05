require "spec"
require "../../src/gradnite"

describe Tensor do
  describe ".new" do
    it "should initialize a tensor with an integer" do
      tensor = Tensor.new(1)
      tensor.value.should eq 1
    end

    it "should initialize a tensor with a float" do
      tensor = Tensor.new(1.23)
      tensor.value.should eq 1.23
    end

    it "should initialize a tensor with a 1D array" do
      tensor = Tensor.new([2, 3, 4])
      tensor.value.should eq [2, 3, 4]
    end

    it "should initialize a tensor with a 2D array" do
      tensor = Tensor.new([[1, 2], [3, 4]])
      tensor.value.should eq [[1, 2], [3, 4]]
    end

    it "should initialize a tensor with a 3D array" do
      tensor = Tensor.new([[[1, 2]], [[3, 4]]])
      tensor.value.should eq [[[1, 2]], [[3, 4]]]
    end
  end

  describe ".full" do
    it "should fill a tensor of the given shape and value" do
      tensor = Tensor.full([2, 2], 1)
      tensor.value.should eq [[1, 1], [1, 1]]
    end
  end

  describe ".zeros" do
    it "should fill a tensor of the given shape with zeros" do
      tensor = Tensor.zeros([2, 2])
      tensor.value.should eq [[0, 0], [0, 0]]
    end
  end

  describe ".ones" do
    it "should fill a tensor of the given shape with ones" do
      tensor = Tensor.ones([2, 2])
      tensor.value.should eq [[1, 1], [1, 1]]
    end
  end

  describe "#size" do
    it "should return an empty array for a scalar tensor" do
      tensor = Tensor.new(1)
      tensor.size.should eq [] of Int32
    end

    it "should return an array with one element for a 1D tensor" do
      tensor = Tensor.new([1, 2, 3])
      tensor.size.should eq [3]
    end

    it "should return an array with two elements for a 2D tensor" do
      tensor = Tensor.new([[1, 2], [3, 4]])
      tensor.size.should eq [2, 2]
    end

    it "should return an array with three elements for a 3D tensor" do
      tensor = Tensor.new([[[1, 2]], [[3, 4]]])
      tensor.size.should eq [2, 1, 2]
    end
  end
end
