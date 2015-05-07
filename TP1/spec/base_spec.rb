require_relative '../src/multi_method.rb'

class A
  partial_def :m, [Object] do |o|
    puts "A METHOD"
    "A>m"
  end
end

class B < A
  partial_def :m, [Integer] do |i|
    #Invocando un objeto, y este objeto conoce al metodo m y elige a que "m" llamar
    puts "B METHOD"
    base.m([Numeric], i) + " => B>m_integer(#{i})"
  end

  partial_def :m, [Numeric] do
    puts "C METHOD"
    base.m([Object], n) + " => B>m_integer(1)"
  end
end

describe 'test punto 4' do

  it 'test base methods' do
    expect(B.new.m(1)).to eq('devuelve "A>m => B>m_numeric => B>m_integer(1)')
  end

end