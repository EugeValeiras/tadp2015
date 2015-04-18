class PartialBlock

  def initialize(input_array,&block)
    @array = input_array
    @block = block
  end

  def matches(*args)
    return false unless args.count == @array.count
    @array.each do |type, index|
      return false unless @array.get(index).is_a?(type)
    end
    true
  end

  def call(*args)
    raise Error unless matches(*args)
    @block.call(*args)
  end

end