require_relative '../src/multi_method'

class Soldado

  attr_reader :nombre

  def initialize(name)
    @nombre = name
  end

end

class Tanque1
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

  partial_def :ataca_a, [Tanque1] do |objetivo|
    self.ataca_con_canion(objetivo)
  end

  partial_def :ataca_a, [Soldado] do |objetivo|
    self.ataca_con_ametralladora(objetivo)
  end
end

class Tanque2
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

  partial_def :ataca_a, [Tanque2] do |objetivo|
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

  tanque1 = Tanque1.new
  soldado = Soldado.new("larala")

  context '' do
    it 'el tanque ataca al soldado' do
      expect(tanque1.ataca_a(soldado)).to eq('TA TA TA TA TA')
    end
    it 'el tanque ataca al tanque' do
      expect(tanque1.ataca_a(tanque1)).to eq('BOOM!')
    end
  end

  context 'los multimethods se pueden agregar y pisar con open classes' do
    #abro la clase tanque
    class Tanque2
      #Agrego una implementación para atacar aviones que NO pisa las anteriores
      partial_def :ataca_a, [Avion] do |avion|
        self.atacar_con_satelite(avion)
      end

      partial_def :ataca_a, [Soldado] do |soldado|
        self.pisar(soldado)
      end
    end

    tanque2 = Tanque2.new
    avion = Avion.new
    soldado = Soldado.new("asdasd")

    it 'el tanque ataca al avion' do
      expect(tanque2.ataca_a(avion)).to eq('PONELE')
    end

    it 'el tanque pida al soldado' do
      expect(tanque2.ataca_a(soldado)).to eq("para eso comprate un auto...")
    end
  end

  context 'multimethods en instancias' do
    tanque_modificado = Tanque1.new

    tanque_modificado.partial_def :tocar_bocina_a, [Soldado] do |soldado|
      "Honk Honk! #{soldado.nombre}"
    end

    tanque_modificado.partial_def :tocar_bocina_a, [Tanque1] do |tanque|
      "Hooooooonk!"
    end

    it 'la instancia tiene el multimethod pero no la clase' do
      expect(tanque_modificado.tocar_bocina_a(Soldado.new("pepe"))).to eq("Honk Honk! pepe")
      expect(tanque_modificado.tocar_bocina_a(Tanque1.new)).to eq("Hooooooonk!")
      expect { Tanque1.new.tocar_bocina_a(Tanque1.new) }.to raise_error(NoMethodError)
    end
  end

  context 'herencia' do
    class Panzer < Tanque1; end

    class PanzerVago < Tanque1
      partial_def :ataca_a, [Soldado] do |soldado|
        "no quiero"
      end
    end

    it 'el panzer tiene que heredar de tanque' do
      panzer = Panzer.new
      expect(panzer.ataca_a(Soldado.new("pepe"))).to eq('TA TA TA TA TA')
    end

    it 'puede redefinir partials heredados' do
      expect(PanzerVago.new.ataca_a(Soldado.new("pepe"))).to eq("no quiero")
      expect(Tanque1.new.ataca_a(Soldado.new("pepe"))).to eq('TA TA TA TA TA')
    end
  end

end
