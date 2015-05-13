class PartialBlock

  attr_reader :types_array, :block

  def initialize(input_array,&input_block)
    @types_array = input_array
    @block = input_block
  end

  def matches(*args)
    return false unless args.count == types_array.count
    types_array.each_with_index do |type, index|
      return false unless args[index].is_a?(type)
    end
    true
  end

=begin
  def matches_classes(*args)
    return false unless args.count == types_array.count
    types_array.each_with_index do |type, index|
      return false unless args[index].ancestors.include?(type)
    end
    true
  end
=end

  def call(*args)
    raise ArgumentError.new unless matches(*args)
    @block.call(*args)
  end

  def with_same_parameters_types(another_partial_block)
    types_array == another_partial_block.types_array
  end

  def afinity(*args)
    afinity = 0
    args.each_with_index do |arg, index|
      afinity += arg.class.ancestors.index(types_array[index]) * (index + 1)
    end
    afinity
  end

end
