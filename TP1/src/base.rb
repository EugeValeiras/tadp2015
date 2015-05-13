class Base

  def initialize(object)
    @object = object
  end

  def method_missing(method_name, *args, &block)
    types_array = args.first
    args = args.drop(1)

    current_class = @object.class
    while (current_class)
      multimethod = current_class.multimethod(method_name)
      partial_block = multimethod.exact_partial_block_for_types(types_array)
      break if partial_block
      current_class = current_class.superclass
    end

    raise NoMultiMethodError.new unless partial_block

    @object.instance_exec(*args, &partial_block.block)
  end

end
