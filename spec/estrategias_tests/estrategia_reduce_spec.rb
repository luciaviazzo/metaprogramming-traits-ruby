require "rspec"
require "trait"
require "estrategia"

describe "Trait - Estrategia reduce" do
  specify "al resolver un conflicto, se combinan los resultados con un reduce" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    una_clase = Class.new
    una_estrategia = Estrategia.reduce(0) { |acc, n| acc + n }
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))

    expect(una_clase.new.m1).to eq(30)
  end

  specify "al resolver un conflicto, los otros métodos siguen funcionando" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
      def m2; 40 end
    end
    otro_trait = Trait.new_from_block { def m1 = 20 }

    una_clase = Class.new
    una_estrategia = Estrategia.reduce(0) { |acc, n| acc + n }
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))

    expect(una_clase.new.m2).to eq(40)
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
    una_estrategia = Estrategia.reduce(0) { |acc, n| acc + n }

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
    una_estrategia = Estrategia.reduce(0) { |acc, n| acc + n }
    un_trait_conflictivo = un_trait + otro_trait
    una_clase.uses(
      un_trait_conflictivo
        .resolver_conflicto(:m1, una_estrategia)
        .resolver_conflicto(:m2, una_estrategia)
    )

    expect(una_clase.new.m1).to eq(30)
    expect(una_clase.new.m2).to eq(70)
  end

  specify "si el trait elegido no tiene el método conflictivo lanza una excepción" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_estrategia = Estrategia.reduce(0) { |acc, n| acc + n }
    un_trait_conflictivo = un_trait + otro_trait

    expect do
      una_clase.uses(un_trait_conflictivo.resolver_conflicto(:m3, una_estrategia))
    end.to raise_error(NoMethodError)
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
    una_estrategia = Estrategia.reduce(0) { |acc, n| acc + n }
    una_clase.uses(
      (un_trait + otro_trait).resolver_conflictos(
        m1: una_estrategia,
        m2: una_estrategia
      )
    )

    expect(una_clase.new.m1).to eq(30)
    expect(una_clase.new.m2).to eq(70)
  end
end
