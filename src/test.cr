struct Mutable
  property value

  def initialize(@value : Int32)
  end
end

mut = Mutable.new 1
mut2 = Mutable.new 1
