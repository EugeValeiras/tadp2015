require 'rspec'
require 'byebug'
require_relative '../src/multi_method'

class A
  partial_def :concat, [String, String] do |s1, s2|
    s1 + s2
  end

  partial_def :concat, [String, Integer] do |s1,n|
    s1 * n
  end

  partial_def :concat, [Array] do |a|
    a.join
  end

  partial_def :concat, [Object, Object] do |o1, o2|
    "Objetos concatenados"
  end
end

class B
  partial_def :concat, [String, Integer] do |s1,n|
    s1 * n
  end

  partial_def :concat, [Object, Object] do |o1, o2|
    "Objetos concatenados"
  end
end

describe 'Implementacion multimethods' do

  context 'class A' do
    it 'define varios multimethods con el mismo nombre' do
      a = A.new
      expect(a.concat('hello', ' world')).to eq('hello world')
      expect(a.concat('hello', 3)).to eq('hellohellohello')
      expect(a.concat(['hello', ' world', '!'])).to eq('hello world!')
      expect { a.concat('hello', 'world', '!') }.to raise_error(NoMultiMethodError)
    end

    it 'retorna la lista de multimethods' do
      expect(A.multimethods()).to eq([:concat])
    end

    it 'retorna referencia a un multimethod' do
      expect(A.multimethod(:concat).name).to eq(:concat)
    end
  end

  context 'class B' do
    it 'elije al multimethod que mejor matchea' do
      b = B.new
      expect(b.concat("Hello", 2)).to eq("HelloHello")
      expect(b.concat(Object.new, 3)).to eq("Objetos concatenados")
    end
  end
end

describe 'multimethods se pisan' do
  class C
    partial_def :saludar_a, [String] do |persona|
      "hola #{persona}"
    end
  end

  class C
    partial_def :saludar_a, [String] do |persona|
      "escuchame #{persona}"
    end
  end

  it 'usa el ultimo multimethod definido' do
    expect(C.new.saludar_a("fresco")).to eq("escuchame fresco")
  end
end

describe 'respond_to?' do
  it 'respond_to? encuentra concat' do
    expect(A.new.respond_to?(:concat)).to be(true)
    expect(A.new.respond_to?(:to_s)).to be(true)
    expect(A.new.respond_to?(:concat, false, [String, String])).to be(true)
    expect(A.new.respond_to?(:concat, false, [Integer, A])).to be(true)
    expect(A.new.respond_to?(:to_s, false, [String])).to be(false)
    expect(A.new.respond_to?(:concat, false, [String, String, String])).to be(false)
  end

end