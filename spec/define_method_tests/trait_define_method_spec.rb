require "rspec"
require "trait"

describe "TraitDefineMethod" do
  specify "define_method define nuevos métodos en un trait existente" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    un_trait.define_method(:m2) { m1 * 2 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect(una_clase.new.respond_to? :m2).to be true
    expect(una_clase.new.m2).to eq(20)
  end

  specify "define_method define nuevos métodos en un trait usado" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    una_clase = Class.new
    una_clase.uses(un_trait)

    un_trait.define_method(:m2) { m1 * 2 }

    expect(una_clase.new.m2).to eq(20)
  end

  specify "define_method agrega el método a los métodos del trait" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    un_trait.define_method(:m2) { 20 }

    expect(un_trait.method_defined?(:m2)).to be true
  end

  specify "define_method propaga el método a todas las clases que usan el trait" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    clase_a = Class.new
    clase_a.uses(un_trait)

    clase_b = Class.new
    clase_b.uses(un_trait)

    un_trait.define_method(:m2) { m1 * 2 }

    expect(clase_a.new.m2).to eq(20)
    expect(clase_b.new.m2).to eq(20)
  end

  specify "define_method no pisa métodos ya definidos en la clase" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    una_clase = Class.new
    una_clase.define_method(:m2) { 99 }
    una_clase.uses(un_trait)

    un_trait.define_method(:m2) { 20 }

    expect(una_clase.new.m2).to eq(99)
  end

  specify "define_method propaga el método a clases que usan traits que usan el trait" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; 20; end
    end

    una_clase = Class.new
    una_clase.uses(otro_trait)

    un_trait.define_method(:m3) { 30 }

    expect(una_clase.new.m3).to eq(30)
  end

  specify "define_method sobreescribe un método existente del trait" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    un_trait.define_method(:m1) { 99 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect(una_clase.new.m1).to eq(99)
  end

  specify "define_method no sobreescribe un método ya instalado por un trait en clases suscritas" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait)
    un_trait.define_method(:m1) { 99 }

    expect(una_clase.new.m1).to eq(10)
  end
end
