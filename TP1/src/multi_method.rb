require_relative 'partial_block'
require_relative 'base'
require 'byebug'

class NoMultiMethodError < NoMethodError; end

class MultiMethod

  attr_reader :name, :partial_blocks

  def initialize(name, *partial_blocks)
    @name = name
    @partial_blocks = partial_blocks
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

  def block_for(types_array)
    @partial_blocks.find { |pb| pb.types_array == types_array }
  end

end

class Object

  def self.add_multimethod(input_name, input_array, &input_block)
    input_name = input_name.to_sym
    mm = multimethod(input_name, false)
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

  def base
    Base.new(self)
  end

  def self.base
    Base.new(instance_eval("self"))
  end

  def self.multimethods
    @multimethods ||= []

    multimethods = []
    current_class = self

    while(!current_class.nil?)
      current_class_multimethods = current_class.instance_variable_get('@multimethods') || []
      multimethods.concat(current_class_multimethods.map { |mm| mm.name })

      current_class = current_class.superclass
    end

    multimethods
  end

  def self.multimethod(name, with_superclass = true)
    @multimethods ||= []

    current_class = self

    while(current_class)
      current_multimethods = current_class.instance_variable_get("@multimethods") || []
      current_multimethod = current_multimethods.find { |mm| mm.name == name }
      return current_multimethod unless current_multimethod.nil?

      current_class = with_superclass && current_class.superclass
    end
  end

  alias_method :old_respond_to?, :respond_to?
  def respond_to?(method_name, private = false, types_array = nil)
    return old_respond_to?(method_name, private) unless types_array
    mm = self.class.multimethod(method_name, false)
    mm ? mm.matches_classes(*types_array) : false
  end

  private

  # Returns the best possible block that matches the given arguments
  def block_for(method_name, *args)
    partial_blocks = []
    current_class = self.class

    while(current_class)
      begin
        break if (current_class.instance_method(method_name).owner == current_class) && !current_class.multimethod(method_name, false)
      rescue
      end

      current_class_multimethods = current_class.instance_variable_get('@multimethods') || []
      current_multimethod = current_class_multimethods.find { |mm| mm.name == method_name }

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
