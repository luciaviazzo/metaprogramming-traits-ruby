require "rspec"
require "trait"

describe "TraitDefineMethodAlias" do
  specify "agregar un método a un trait después de un renombre lo propaga al trait con renombre" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    trait_con_renombre = un_trait << { m1: :m2 }
    un_trait.define_method(:m3) { 30 }

    una_clase = Class.new
    una_clase.uses(trait_con_renombre)

    expect(una_clase.new.m3).to eq(30)
  end

  specify "agregar un método a un trait después de un renombre lo propaga al trait con renombre usado" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    trait_con_renombre = un_trait << { m1: :m2 }

    una_clase = Class.new
    una_clase.uses(trait_con_renombre)
    un_trait.define_method(:m3) { 30 }

    expect(una_clase.new.m3).to eq(30)
  end

  specify "define_method propaga a un alias de alias" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait << { m1: :m2 } << { m2: :m3 })
    un_trait.define_method(:m4) { 40 }

    expect(una_clase.new.m4).to eq(40)
  end
end
