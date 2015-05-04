require_relative 'partial_block'
require 'byebug'

class NoMultiMethodError < NoMethodError; end

class MultiMethod

  attr_reader :name, :partial_blocks

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
      block = block_for(input_name, *args)
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

  private

  def block_for(method_name, *args)
    partial_blocks = []
    current_class = self.class

    while(!current_class.nil?)
      begin
        break if (current_class.instance_method(method_name).owner == current_class) && !current_class.multimethod(method_name)
      rescue
      end

      current_class_multimethods = current_class.instance_variable_get('@multimethods') || []
      current_multimethod = current_class_multimethods
                                 .select { |mm| mm.name == method_name }
                                 .first

      unless current_multimethod.nil?
        current_multimethod.partial_blocks.each do |pb|
          unless partial_blocks.any? { |block| block.types_array == pb.types_array }
            partial_blocks << pb
          end
        end
      end

      current_class = current_class.superclass
    end

    best_pb = partial_blocks.select { |pb| pb.matches(*args) }
                             .sort_by { |pb| pb.afinity(*args) }
                             .first
    return best_pb.block if best_pb
    raise NoMultiMethodError.new
  end

end
