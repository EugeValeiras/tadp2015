require_relative 'partial_block'

class NoMultiMethodError < NoMethodError; end

class MultiMethod

  attr_reader :name

  def initialize(name, partial_block)
    @name = name
    @partial_blocks = [partial_block]
  end

  def add_partial_block(partial_block)
    @partial_blocks.delete_if { |pb| pb.with_same_parameters_types(partial_block) }
    @partial_blocks.push(partial_block)
  end

  def matches(*args)
    @partial_blocks.any? { |pb| pb.matches(*args) }
  end

  def matches_classes(*args)
    @partial_blocks.any? { |pb| pb.matches_classes(*args) }
  end

  def block_for(*args)
    best_pb = @partial_blocks.select { |pb| pb.matches(*args) }
                             .sort_by { |pb| pb.afinity(*args) }
                             .first
    return best_pb.block if best_pb
    raise NoMultiMethodError.new
  end

end

class Object

  def self.add_multimethod(input_name, input_array, &input_block)
    input_name = input_name.to_sym
    mm = multimethod(input_name)
    partial_block = PartialBlock.new(input_array, &input_block)

    if mm
      mm.add_partial_block(partial_block)
      return
    end

    @multimethods.push(MultiMethod.new(input_name, partial_block))
  end

  def self.partial_def(input_name, input_array, &input_block)
    add_multimethod(input_name, input_array, &input_block)
    define_method(input_name) { |*args|
      block = self.class.multimethod(input_name).block_for(*args)
      instance_exec(*args, &block)
    }
  end

  def partial_def(input_name, input_array, &input_block)
    self.singleton_class.add_multimethod(input_name, input_array, &input_block)
    define_singleton_method(input_name) { |*args|
      block = self.singleton_class.multimethod(input_name).block_for(*args)
      instance_exec(*args, &block)
    }
  end

  def self.multimethods
    @multimethods ||= []
    @multimethods.map { |mm| mm.name }
  end

  def self.multimethod(name)
    @multimethods ||= []
    @multimethods.select { |mm| mm.name == name }.first
  end

  alias_method :old_respond_to?, :respond_to?
  def respond_to?(method_name, private = false, types_array = nil)
    return old_respond_to?(method_name, private) unless types_array
    mm = self.class.multimethod(method_name)
    mm ? mm.matches_classes(*types_array) : false
  end

end
