class PartialBlock

  def initialize(input_array,&block)
    @array = input_array
    @block = block
  end

  def matches(*args)
    return false unless args.count == @array.count
    @array.each_with_index do |type, index|
      return false unless args[index].is_a?(type)
    end
    true
  end

  def call(*args)
    raise 'Ha ocurrido un error' unless matches(*args)
    @block.call(*args)
  end

end