require 'rspec'
require_relative './partial_block'

describe 'Implementación partial_block' do

  helloBlock = PartialBlock.new([String]) do |who|
    "Hello #{who}"
  end

  it 'Matchean los parámetros?' do

    expect(helloBlock.matches("a")).to be true
    expect(helloBlock.matches(1)).to be false
    expect(helloBlock.matches("a","b")).to be false
  end


  it 'Puede realizar call?' do

    (helloBlock.call("world!")).should == 'Hello world!'
  end

  it 'Debería dar error' do

    expect{ helloBlock.call(1) }.to raise_error(ArgumentError)
  end

  it 'Partial_Block funciona con instancias de subtipos de los que define' do

    pairBlock = PartialBlock.new([Object, Object]) do |left, right|
      [left, right]
    end

    (pairBlock.call("hello", 1)).should == ["hello",1]
  end

  it 'Partial_Block sin argumentos' do

    pi = PartialBlock.new([]) do
      3.14159265359
    end

    expect(pi.call()).to eq 3.14159265359
    expect(pi.matches()).to be true
  end
end
