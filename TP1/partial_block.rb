class PartialBlock

  def initialize(input_array,&input_block)
    @array = input_array
    @block = input_block
  end

  def matches(*args)
    return false unless args.count == @array.count
    @array.each_with_index do |type, index|
      return false unless args[index].is_a?(type)
    end
    true
  end

  def call(*args)
    raise ArgumentError.new unless matches(*args)
    #--raise 'PAPI, LOS PARAMETROS NO MATCHEAN' unless matches(*args)
    @block.call(*args)
  end

end