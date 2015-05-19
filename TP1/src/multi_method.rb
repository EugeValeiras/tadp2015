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
    args = args.map { |arg| arg.class }
    matches_classes(*args)
  end

  def matches_classes(*args)
    @partial_blocks.any? { |pb| pb.matches_classes(*args)}
  end

  def exact_partial_block_for_types(types_array)
    @partial_blocks.find { |pb| pb.types_array == types_array }
  end

  #Auxiliar method
  def self.partial_blocks_for_method(method_name, current_class)
    partial_blocks = []

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

      # (codigo + logica repetida muchas veces)
      # si sube por "superclass" no va a encontrar a los modulos
      # ej: String.superclass = Object
      # String.ancestors = [String, Comparable, Object,...
      current_class = current_class.superclass
    end
    return partial_blocks if partial_blocks

    raise NoMultiMethodError.new
  end

end

class Object
  attr_reader :multimethods

  def self.add_multimethod(input_name, input_array, &input_block)
    input_name = input_name.to_sym
    mm = multimethod(input_name, false)
    partial_block = PartialBlock.new(input_array, &input_block)

    if mm
      mm.add_partial_block(partial_block)
    else
      @multimethods.push(MultiMethod.new(input_name, partial_block))
    end
  end

  def self.partial_def(input_name, input_array, &input_block)
    add_multimethod(input_name, input_array, &input_block)
    define_method(input_name) { |*args|
      partial_blocks = MultiMethod.partial_blocks_for_method(input_name, self.singleton_class)
      best_partial_block = partial_blocks.select { |pb| pb.matches(*args) }
                                         .sort_by { |pb| pb.afinity(*args) }
                                         .first

      raise NoMultiMethodError.new unless best_partial_block
      instance_exec(*args, &best_partial_block.block)
    }
  end

  def partial_def(input_name, input_array, &input_block)
    self.singleton_class.partial_def(input_name, input_array, &input_block)
  end

  def base
    Base.new(self)
  end

  def self.multimethods
    @multimethods ||= []

    multimethods = []
    current_class = self

    while(!current_class.nil?)
      current_class_multimethods = current_class.instance_variable_get('@multimethods') || []
      multimethods.concat(current_class_multimethods.map { |mm| mm.name })

      # si sube por "superclass" no va a encontrar a los modulos
      # ej: String.superclass = Object
      # String.ancestors = [String, Comparable, Object,...
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

      # (codigo repetido con "multimethods")
      # si sube por "superclass" no va a encontrar a los modulos
      # ej: String.superclass = Object
      # String.ancestors = [String, Comparable, Object,...
      current_class = with_superclass && current_class.superclass
    end
  end

  alias_method :old_respond_to?, :respond_to?
  def respond_to?(method_name, private = false, types_array = nil)
    return old_respond_to?(method_name, private) unless types_array
    mm = self.class.multimethod(method_name, false)
    mm ? mm.matches(*types_array) : false
  end

end
