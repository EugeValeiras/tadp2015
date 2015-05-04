require_relative '../src/multi_method.rb'

class AAA

  partial_def :concat, [Object, Object] { |o1,o2| 'a'}
  partial_def :suma, [Integer, Integer] { |p1, p2| 'a' }
  partial_def :multiplico, [Integer, Integer] { |i1, i2| 'a'}
  partial_def :suma5, [Integer] {|i| 'a'}

end

class BBB < AAA

  partial_def :concat, [Array] { |a1| 'b'}
  partial_def :multiplico, [Object, Object] { |o1, i2| 'b'}
  partial_def :suma3, [Integer] { |i| 'b' }
  partial_def :suma4, [] {'b'}
  def suma5(asdas)
    'b'
  end

end

class CCC < BBB

  partial_def :concat, [String, String] { |s1,s2| 'c'}
  partial_def :suma, [Object, Object] { |p1, p2| 'c' }
  partial_def :suma2, [Integer] { |p1| 'c' }
  partial_def :suma3, [Integer] { |i| 'c' }
  def suma4
    'c'
  end
  partial_def :suma5, [Object] {|o| 'c'}
end

aa = AAA.new
bb = BBB.new
cc = CCC.new

describe 'suma' do

  it 'suma en c con dos objetos' do
    expect(cc.suma(Object.new, Object.new)).to eq('c')
  end

  it 'suma en c con dos enteros' do
    expect(cc.suma(2, 1)).to eq('a')
  end

  it 'suma en b con dos objetos' do
    expect { bb.suma(Object.new, Object.new) }.to raise_error(NoMultiMethodError)
  end

  it 'suma en b con dos enteros' do
    expect(bb.suma(2, 1)).to eq('a')
  end

  it 'suma en a con dos objetos' do
    expect { aa.suma(Object.new, Object.new) }.to raise_error(NoMultiMethodError)
  end

  it 'suma en a con dos enteros' do
    expect(aa.suma(2, 1)).to eq('a')
  end

end

describe 'suma2' do

  it 'suma2 en c con un entero' do
    expect(cc.suma2(2)).to eq('c')
  end

  it 'suma2 en c con un objeto' do
    expect{ cc.suma2(Object.new) }.to raise_error(NoMultiMethodError)
  end

  it 'suma2 en b con un entero' do
    expect{ bb.suma2(2) }.to raise_error(NoMethodError)
  end

  it 'suma2 en a con un entero' do
    expect{ aa.suma2(2) }.to raise_error(NoMethodError)
  end

end

describe 'suma3' do

  it 'suma3 en c con un entero' do
    expect(cc.suma3(3)).to eq('c')
  end

  it 'suma3 en b con un entero' do
    expect(bb.suma3(3)).to eq('b')
  end

end

describe 'suma4' do

  it 'suma4 en c' do
    expect(cc.suma4).to eq('c')
  end

  it 'suma4 en b' do
    expect(bb.suma4).to eq('b')
  end

end


describe 'suma5' do

  it 'suma5 en c con un entero' do
    expect(cc.suma5(5)).to eq('c')
  end

  it 'suma5 en c con un object' do
    expect(cc.suma5(Object.new)).to eq('c')
  end

  it 'suma5 en b' do
    expect(bb.suma5(2)).to eq('b')
  end

  it 'suma5 en a con un entero' do
    expect(aa.suma5(5)).to eq('a')
  end

  it 'suma5 en a con un object' do
    expect{ aa.suma5(Object.new) }.to raise_error(NoMultiMethodError)
  end

end

describe 'multiplico' do

  it 'multiplico en c con dos objetos' do
    expect(cc.multiplico(Object.new, Object.new)).to eq('b')
  end

  it 'multiplico en c con dos enteros' do
    expect(cc.multiplico(2, 2)).to eq('a')
  end

  it 'multiplico en b con dos objetos' do
    expect(bb.multiplico(Object.new, Object.new)).to eq('b')
  end

  it 'multiplico en b con dos enteros' do
    expect(bb.multiplico(2, 1)).to eq('a')
  end

  it 'multiplico en a con dos objetos' do
    expect { aa.multiplico(Object.new, Object.new) }.to raise_error(NoMultiMethodError)
  end

  it 'multiplico en a con dos enteros' do
    expect(aa.multiplico(2, 1)).to eq('a')
  end

end

describe 'concat' do

it 'concat en c con dos String' do
    expect(cc.concat('a', 'b')).to eq('c')
end

it 'concat en c con Array' do
    expect(cc.concat([])).to eq('b')
end

it 'concat en c con dos Object' do
    expect(cc.concat(Object.new, Object.new)).to eq('a')
end

it 'concat en b con dos String' do
    expect(bb.concat('a', 'a')).to eq('a')
end

it 'concat en b con Array' do
    expect(bb.concat([])).to eq('b')
end

it 'concat en b con dos Object' do
    expect(bb.concat(Object.new, Object.new)).to eq('a')
end

it 'concat en a con dos String' do
    expect(aa.concat('s', 'a')).to eq('a')
end

it 'concat en a con Array' do
    expect{aa.concat([])}.to raise_error(NoMultiMethodError)
end

it 'concat en a con dos Object' do
    expect(aa.concat(Object.new, Object.new)).to eq('a')
end

end
