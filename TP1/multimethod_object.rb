require_relative 'partial_block'

class Object

  def self.partial_def(input_name,input_array,&input_block)
    define_method(input_name){ |*args|
      PartialBlock.new(input_array,&input_block).call(*args)
    }
  end

end


class A
  partial_def :concat, [String,String] do |s1, s2|
    s1 + s2
  end

  partial_def :concat, [String] do |who| "#{who}" end
end

puts(A.new.concat("Hola"))