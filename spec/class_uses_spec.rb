require "rspec"
require "trait"

describe "Class - Uses" do
  #Comportamiento básico
  specify "una clase puede responder los métodos definidos en sus traits" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect(una_clase.new.m1).to eq(10)
  end

  specify "llamar un método que el trait no define lanza una excepción" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect do
      una_clase.new.m2
    end.to raise_error(NoMethodError)
  end

  specify "usar algo que no es un trait lanza una excepción" do
    una_clase = Class.new
    expect { una_clase.uses(1) }.to raise_error(NoEsUnTrait)
  end

  specify "una clase puede usar múltiples traits" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait)
    una_clase.uses(otro_trait)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
  end

  #Prioridad de métodos
  specify "la clase gana sobre el trait cuando ambos definen el mismo método" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.define_method(:m1) { 20 }
    una_clase.uses(un_trait)

    expect(una_clase.new.m1).to eq(20)
  end

  specify "la superclase gana sobre el trait cuando ambos definen el mismo método" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    superclase = Class.new
    superclase.define_method(:m1) { 20 }
    una_clase = Class.new(superclase)
    una_clase.uses(un_trait)

    expect(una_clase.new.m1).to eq(20)
  end

  specify "Si una clase usa dos traits que definen el mismo método, gana el primero" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 15 }

    una_clase = Class.new
    una_clase.uses(un_trait)
    una_clase.uses(otro_trait)

    expect(una_clase.new.m1).to eq(10)
  end
end
