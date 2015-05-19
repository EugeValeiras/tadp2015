require_relative '../src/multi_method.rb'

class AAAA
  partial_def :m, [Object] do |o|
    "A>m"
  end
end

class BBBB < AAAA

  partial_def :m, [Integer] do |i|
    base.m([Numeric], i) + " => B>m_integer(#{i})"
  end

  partial_def :m, [Numeric] do |n|
    base.m([Object], n) + " => B>m_numeric"
  end

  partial_def :m2, [Object, String] do |obj, str|
    obj.to_s + str
  end

  partial_def :m2, [String, String] do |str1, str2|
    base.m2([Object, String], str1, str2) + "?"
  end

end


bbbb = BBBB.new

describe 'm' do

it 'm with int' do
  expect(bbbb.m(1)).to eq("A>m => B>m_numeric => B>m_integer(1)")
end

  it 'base funciona con dos parametros' do
    expect(bbbb.m2("hola ", "mundo")).to eq("hola mundo?")
  end

end