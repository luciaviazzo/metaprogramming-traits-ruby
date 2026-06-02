require "rspec"
require "trait"
require "estrategia"

RSpec.describe "Trait - Estrategia elegir trait" do
  specify "al resolver un conflicto, se usa el método del trait elegido" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    una_clase = Class.new
    una_estrategia = Estrategia.elegir_trait(un_trait)
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))

    expect(una_clase.new.m1).to eq(10)
  end

  specify "al resolver un conflicto, los otros métodos siguen funcionando" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
      def m2; 30; end
    end

    otro_trait = Trait.new_from_block do
      def m1; 20; end
      def m3; 40; end
    end

    una_clase = Class.new
    una_estrategia = Estrategia.elegir_trait(un_trait)
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(30)
    expect(una_clase.new.m3).to eq(40)
  end

  specify "al resolver un conflicto, los otros conflictos no resueltos se mantienen" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
      def m2; 30; end
    end

    otro_trait = Trait.new_from_block do
      def m1; 20; end
      def m2; 40; end
    end

    una_clase = Class.new
    una_estrategia = Estrategia.elegir_trait(un_trait)

    expect do
      una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))
    end.to raise_error(TraitConConflictos)
  end

  specify "se pueden resolver múltiples conflictos con distintas estrategias" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
      def m2; 30; end
    end

    otro_trait = Trait.new_from_block do
      def m1; 20; end
      def m2; 40; end
    end

    una_clase = Class.new
    un_trait_conflictivo = un_trait + otro_trait
    una_clase.uses(
      un_trait_conflictivo
        .resolver_conflicto(:m1, Estrategia.elegir_trait(un_trait))
        .resolver_conflicto(:m2, Estrategia.elegir_trait(otro_trait))
    )

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(40)
  end

  specify "si el trait elegido no tiene el método conflictivo lanza una excepción" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    un_trait_sin_relacion = Trait.new_from_block do
      def m2; 30; end
    end

    una_clase = Class.new
    una_estrategia = Estrategia.elegir_trait(un_trait_sin_relacion)
    un_trait_conflictivo = un_trait + otro_trait

    expect do
      una_clase.uses(un_trait_conflictivo.resolver_conflicto(:m1, una_estrategia))
    end.to raise_error(NoMethodError)
  end

  specify "resolver un conflicto mantiene la conmutatividad" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block do
      def m1; 20; end
      def m2; 30; end
    end

    una_estrategia = Estrategia.elegir_trait(un_trait)

    clase_izq = Class.new
    clase_izq.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))

    clase_der = Class.new
    clase_der.uses((otro_trait + un_trait).resolver_conflicto(:m1, una_estrategia))

    expect(clase_izq.new.m1).to eq(10)
    expect(clase_der.new.m1).to eq(10)
    expect(clase_izq.new.m2).to eq(30)
    expect(clase_der.new.m2).to eq(30)
  end

  specify "se pueden resolver múltiples conflictos con resolver_conflictos" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
      def m2; 30; end
    end

    otro_trait = Trait.new_from_block do
      def m1; 20; end
      def m2; 40; end
    end

    una_clase = Class.new
    una_clase.uses(
      (un_trait + otro_trait).resolver_conflictos(
        m1: Estrategia.elegir_trait(un_trait),
        m2: Estrategia.elegir_trait(otro_trait)
      )
    )

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(40)
  end
end
