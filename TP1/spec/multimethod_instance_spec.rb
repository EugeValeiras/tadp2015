require_relative '../src/multi_method'

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
