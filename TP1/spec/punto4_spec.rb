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

end


bbbb = BBBB.new

describe 'm' do

it 'm with int' do
  expect(bbbb.m(1)).to eq("A>m => B>m_numeric => B>m_integer(1)")

end

end