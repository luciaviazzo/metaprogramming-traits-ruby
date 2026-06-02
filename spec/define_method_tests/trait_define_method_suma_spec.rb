require "rspec"
require "trait"

describe "TraitDefineMethodSuma" do
  specify "define_method define nuevos métodos en una suma de traits" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      def m2; 20 end
    end

    una_clase = Class.new
    suma = un_trait + otro_trait
    una_clase.uses(suma)
    suma.define_method(:m3) { m1 + m2 + 30 }

    expect(una_clase.new.m3).to eq(60)
  end

  specify "define_method propaga los nuevos métodos en una suma de traits" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      def m2; 20 end
    end

    una_clase = Class.new
    una_clase.uses(un_trait + otro_trait)
    un_trait.define_method(:m3) { 30 }

    expect(una_clase.new.m3).to eq(30)
  end

  specify "agregar un método a un trait después de la suma lo propaga al trait suma" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    trait_suma = un_trait + otro_trait
    un_trait.define_method(:m3) { 30 }

    una_clase = Class.new
    una_clase.uses(trait_suma)

    expect(una_clase.new.m3).to eq(30)
  end

  specify "agregar un método a un trait después de la suma lo propaga al trait suma usado" do
    trait1 = Trait.new_from_block { def m1 = 10 }
    trait2 = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(trait1 + trait2)
    trait1.define_method(:m3) { 30 }

    expect(una_clase.new.m3).to eq(30)
  end

  specify "define_method propaga a una suma de sumas" do
    trait1 = Trait.new_from_block { def m1 = 10 }
    trait2 = Trait.new_from_block { def m2 = 20 }
    trait3 = Trait.new_from_block { def m3 = 30 }

    una_clase = Class.new
    una_clase.uses((trait1 + trait2) + trait3)
    trait1.define_method(:m4) { 40 }

    expect(una_clase.new.m4).to eq(40)
  end
end
