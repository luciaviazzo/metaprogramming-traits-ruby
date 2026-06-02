require "rspec"
require "trait"

describe "Trait - Suma" do
  #Comportamiento básico
  specify "se pueden combinar dos traits y usar ambos métodos" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait + otro_trait)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
  end

  specify "sumar algo que no es un trait lanza TypeError" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    expect { un_trait + 1 }.to raise_error(TypeError)
  end

  #Requeridos
  specify "un requerimiento puede ser satisfecho por otro trait" do
    un_trait = Trait.new_from_block { requires :m2; def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait + otro_trait)

    expect(una_clase.new.m1).to eq(10)
  end

  specify "dos traits pueden satisfacer sus requerimientos mutuamente" do
    un_trait = Trait.new_from_block { requires :m2; def m1 = 10 }
    otro_trait = Trait.new_from_block { requires :m1; def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait + otro_trait)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
  end

  specify "un requerimiento no satisfecho sigue siendo requerido en la suma" do
    un_trait = Trait.new_from_block { requires :m1 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    trait_suma = un_trait + otro_trait
    expect(trait_suma.requires?(:m1)).to be true
  end

  #Conflictos
  specify "dos traits con el mismo metodo generan un conflicto" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    una_clase = Class.new

    expect { una_clase.uses(un_trait + otro_trait) }.to raise_error(TraitConConflictos)
  end

  specify "usar un trait con conflictos sin resolver lanza una excepción" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    una_clase = Class.new
    expect { una_clase.uses(un_trait + otro_trait) }.to raise_error(TraitConConflictos)
  end

  #Propiedades
  specify "la suma entre dos traits es conmutativa (Atacante + Defensor == Defensor + Atacante)" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait + otro_trait)
    otra_clase = Class.new
    otra_clase.uses(otro_trait + un_trait)

    expect(una_clase.new.m1).to eq(otra_clase.new.m1)
    expect(una_clase.new.m2).to eq(otra_clase.new.m2)
  end

  specify "la suma de un trait consigo mismo es idempotente (Atacante + Atacante == Atacante)" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait + un_trait)

    expect(una_clase.new.m1).to eq(10)
  end

  specify "la suma de la suma es idempotente" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait) + (un_trait + otro_trait))

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
  end

  specify "la suma es idempotente y conmutativa simultaneamente" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait) + (otro_trait + un_trait))

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
  end
end
