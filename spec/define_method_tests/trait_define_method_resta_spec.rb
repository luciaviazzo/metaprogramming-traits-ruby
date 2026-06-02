require "rspec"
require "trait"

describe "TraitDefineMethodResta" do
  specify "agregar un método a un trait después de la resta lo propaga al trait resta" do
    un_trait = Trait.new_from_block { def m1 = 10; def m2 = 20 }

    trait_resta = un_trait - :m2
    un_trait.define_method(:m3) { 30 }

    una_clase = Class.new
    una_clase.uses(trait_resta)

    expect(una_clase.new.m3).to eq(30)
  end

  specify "agregar un método a un trait después de la resta lo propaga al trait resta usado" do
    un_trait = Trait.new_from_block { def m1 = 10; def m2 = 20 }

    trait_resta = un_trait - :m2

    una_clase = Class.new
    una_clase.uses(trait_resta)

    un_trait.define_method(:m3) { 30 }

    expect(una_clase.new.m3).to eq(30)
  end

  specify "define_method propaga a una resta de resta" do
    un_trait = Trait.new_from_block { def m1 = 10; def m2 = 20; def m3 = 30 }

    una_clase = Class.new
    una_clase.uses((un_trait - :m2) - :m3)
    un_trait.define_method(:m4) { 40 }

    expect(una_clase.new.m4).to eq(40)
  end
end
