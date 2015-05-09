require_relative '../src/multi_method.rb'

class AEnunciado
  partial_def :m, [String] do |s|
      "A>m #{s}"
  end

  partial_def :m, [Numeric] do |n|
      "A>m" * n
  end

  partial_def :m, [Object] do |o|
      "A>m and Object"
  end

end

class BEnunciado < AEnunciado
  partial_def :m, [Object] do |o|
    "B>m and Object"
  end
end

b = BEnunciado.new
a = AEnunciado.new

describe 'm' do

  it 'm en clase B con String' do
    expect(b.m("hello")).to eq('A>m hello')
  end

  it 'm en clase B con Object' do
    expect(b.m(Object.new)).to eq('B>m and Object')
  end

  it 'm en clase B con Numeric' do
    expect(b.m(3)).to eq("A>mA>mA>m")
  end

##############################################################
  it 'm en clase A con String' do
    expect(a.m("hello")).to eq('A>m hello')
  end

  it 'm en clase A con Object' do
    expect(a.m(Object.new)).to eq("A>m and Object")
  end

  it 'm en clase A con Numeric' do
    expect(a.m(3)).to eq("A>mA>mA>m")
  end

end