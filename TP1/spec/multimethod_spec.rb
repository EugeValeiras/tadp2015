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


class Soldado

  attr_reader :nombre

  def initialize(name)
    @nombre = name
  end

end

class Tanque

  def ataca_con_canion(objetivo)
    "BOOM!"
  end

  def ataca_con_ametralladora(objetivo)
    "TA TA TA TA TA"
  end

  def pisar(objetivo)
    "para eso comprate un auto..."
  end

  def atacar_con_satelite(objetivo)
    "PONELE"
  end

  partial_def :ataca_a, [Tanque] do |objetivo|
    self.ataca_con_canion(objetivo)
  end

  partial_def :ataca_a, [Soldado] do |objetivo|
      self.ataca_con_ametralladora(objetivo)
  end
end

class Avion
  #... implementación de avión
end

describe 'Multimethods en tanque, soldado y avion' do

  tanque = Tanque.new
  soldado = Soldado.new("larala")

  context '' do
    it 'el tanque ataca al soldado' do
      expect(tanque.ataca_a(soldado)).to eq('TA TA TA TA TA')
    end
    it 'el tanque ataca al tanque' do
      expect(tanque.ataca_a(tanque)).to eq('BOOM!')
    end
  end

  context 'los multimethods se pueden agregar y pisar con open classes' do
    #abro la clase tanque
    class Tanque
      #Agrego una implementación para atacar aviones que NO pisa las anteriores
      partial_def :ataca_a, [Avion] do |avion|
        self.atacar_con_satelite(avion)
      end
    end

    tanque = Tanque.new
    avion = Avion.new
    soldado = Soldado.new("asdasd")

    it 'el tanque ataca al avion' do
      expect(tanque.ataca_a(avion)).to eq('PONELE')
    end
  end

  context 'multimethods en instancias' do
    tanque_modificado = Tanque.new

    tanque_modificado.partial_def :tocar_bocina_a, [Soldado] do |soldado|
      "Honk Honk! #{soldado.nombre}"
    end

    tanque_modificado.partial_def :tocar_bocina_a, [Tanque] do |tanque|
      "Hooooooonk!"
    end

    it 'la instancia tiene el multimethod pero no la clase' do
      expect(tanque_modificado.tocar_bocina_a(Soldado.new("pepe"))).to eq("Honk Honk! pepe")
      expect(tanque_modificado.tocar_bocina_a(Tanque.new)).to eq("Hooooooonk!")
      expect { Tanque.new.tocar_bocina_a(Tanque.new) }.to raise_error(NoMethodError)
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