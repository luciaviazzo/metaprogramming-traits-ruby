require "rspec"
require "trait"

describe "Trait - Alias" do
  specify "al renombrar un metodo, la clase puede responder con el nuevo nombre" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait << { m1: :m2 })

    expect(una_clase.new.m2).to eq(10)
  end

  specify "al renombrar un metodo, la clase puede responder el original" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait << { m1: :m2 })

    expect(una_clase.new.respond_to?(:m1)).to eq(true)
  end

  specify "al renombrar varios metodos, la clase puede responder todos los nuevos" do
    un_trait = Trait.new_from_block { def m1 = 10; def m3 = 30 }

    una_clase = Class.new
    una_clase.uses(un_trait << { m1: :m2, m3: :m4 })

    expect(una_clase.new.m2).to eq(10)
    expect(una_clase.new.m4).to eq(30)
  end

  specify "al renombrar varios metodos, la clase puede responder los originales" do
    un_trait = Trait.new_from_block { def m1 = 10; def m3 = 30 }

    una_clase = Class.new
    una_clase.uses(un_trait << { m1: :m2, m3: :m4 })

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m3).to eq(30)
  end

  specify "al renombrar un metodo ya definido, se sobreescribe la definición" do
    un_trait = Trait.new_from_block { def m1 = 10; def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait << { m1: :m2 })

    expect(una_clase.new.m2).to eq(10)
  end

  specify "alias de un método a sí mismo no cambia el comportamiento" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    una_clase = Class.new
    una_clase.uses(un_trait << { m1: :m1 })

    expect(una_clase.new.m1).to eq(10)
  end

  specify "renombrar un método inexistente lanza una excepción" do
    un_trait = Trait.new_from_block {}

    expect { un_trait << { m1: :m2 } }.to raise_error(NoMethodError)
  end

  specify "pasar algo que no es un hash lanza una excepción" do
    un_trait = Trait.new_from_block {}

    expect { un_trait << [:m1, :m2] }.to raise_error(TypeError)
  end

  specify "pasar claves que no son símbolos lanza una excepción" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    expect { un_trait << { "m1" => :m2 } }.to raise_error(TypeError)
  end

  specify "pasar valores que no son símbolos lanza excepción" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    expect { un_trait << { m1: "m2" } }.to raise_error(TypeError)
  end

  specify "se pueden encadenar alias correctamente" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait << { m1: :m2 } << { m2: :m3 })

    expect(una_clase.new.m3).to eq(10)
  end

  #Combinación con suma y resta
  specify "Al renombrar un metodo y luego sumar otro trait, la clase puede responder ambos" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    otro_trait = Trait.new_from_block { def m3 = 30 }

    una_clase = Class.new
    una_clase.uses((un_trait << { m1: :m2 }) + otro_trait)

    expect(una_clase.new.m2).to eq(10)
    expect(una_clase.new.m3).to eq(30)
  end

  specify "al sumar otro trait y luego renombrar un metodo, la clase lo puede responder el nuevo" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait) << { m1: :m3 })

    expect(una_clase.new.m3).to eq(10)
  end

  specify "al renombrar un metodo y luego restar el original, la clase solo responde el nuevo" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses((un_trait << { m1: :m2 }) - :m1)

    expect(una_clase.new.respond_to?(:m1)).to eq(false)
    expect(una_clase.new.m2).to eq(10)
  end

  specify "al renombrar un metodo para resolver un conflicto, la clase lo puede responder" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    una_clase = Class.new
    una_clase.uses(((un_trait << { m1: :m2 }) - :m1) + ((otro_trait << { m1: :m3 }) - :m1))
    una_clase.define_method(:m1) { m2 + m3 }

    expect(una_clase.new.m1).to eq(30)
  end

  specify "al renombrar generando un conflicto, lanza una excepción" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    expect { una_clase.uses((un_trait << { m1: :m2 }) + otro_trait) }.to raise_error(TraitConConflictos)
  end

  specify "el alias apunta al mismo método que el original" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    trait_con_alias = un_trait << { m1: :m1_alias }

    una_clase = Class.new
    una_clase.uses(trait_con_alias)

    expect(una_clase.new.m1_alias).to eq(10)
    expect(una_clase.new.m1).to eq(10)
    expect(trait_con_alias.instance_method(:m1_alias)).to eq(trait_con_alias.instance_method(:m1))
  end
end
