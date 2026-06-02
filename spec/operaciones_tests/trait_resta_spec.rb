require "rspec"
require "trait"

describe "Trait - Resta" do
  #Comportamiento básico
  specify "se puede excluir un metodo de un trait" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait - :m1)

    expect { una_clase.new.m1 }.to raise_error(NoMethodError)
  end

  specify "excluir un método que no existe no lanza error" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    expect { un_trait - :m2 }.not_to raise_error
  end

  specify "excluir algo que no es símbolo lanza TypeError" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    expect { un_trait - "m1" }.to raise_error(TypeError)
  end

  specify "el trait original no se modifica al restar" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    un_trait - :m1

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect(una_clase.new.m1).to eq(10)
  end

  specify "se pueden excluir múltiples métodos encadenando -" do
    un_trait = Trait.new_from_block { def m1 = 10; def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait - :m1 - :m2)

    expect(una_clase.new.respond_to?(:m1)).to eq(false)
    expect(una_clase.new.respond_to?(:m2)).to eq(false)
  end

  specify "se pueden excluir múltiples métodos con un array" do
    un_trait = Trait.new_from_block { def m1 = 10; def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait - [:m1, :m2])

    expect(una_clase.new.respond_to?(:m1)).to eq(false)
    expect(una_clase.new.respond_to?(:m2)).to eq(false)
  end

  #Requeridos
  specify "se puede excluir un método requerido" do
    un_trait = Trait.new_from_block { requires :m1 }
    trait_sin_requerido = un_trait - :m1

    expect(trait_sin_requerido.requires?(:m1)).to be false
  end

  #Combinacion con suma
  specify "excluir un metodo resuelve un conflicto entre traits" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait + (otro_trait - :m1))

    expect(una_clase.new.m1).to eq(10)
  end

  specify "excluir todos los métodos conflictivos hace que la clase no responda a ese mensaje" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait) - :m1)

    expect(una_clase.new.respond_to?(:m1)).to eq(false)
  end
end
