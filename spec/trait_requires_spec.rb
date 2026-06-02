require "rspec"
require "trait"

describe "Trait - requires" do
  #Comportamiento básico
  specify "un trait puede requerir métodos que la clase debe implementar" do
    un_trait = Trait.new_from_block { requires :m1 }

    una_clase = Class.new
    una_clase.define_method(:m1) { 10 }
    una_clase.uses(un_trait)

    expect(una_clase.new.m1).to eq(10)
  end

  specify "un trait puede usar el método requerido en su propia implementación" do
    un_trait = Trait.new_from_block { requires :m1; def m2 = m1 + 10 }

    una_clase = Class.new
    una_clase.define_method(:m1) { 10 }
    una_clase.uses(un_trait)

    expect(una_clase.new.m2).to eq(20)
  end

  specify "no implementar el método requerido lanza una excepción al llamarlo" do
    un_trait = Trait.new_from_block { requires :m1 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect { una_clase.new.m1 }.to raise_error(MetodoRequerido)
  end

  specify "no implementar el método requerido lanza una excepción al usar un método que lo necesita" do
    un_trait = Trait.new_from_block { requires :m1; def m2 = m1 + 10 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect { una_clase.new.m2 }.to raise_error(MetodoRequerido)
  end

  #Múltiples requeridos
  specify "un trait puede requerir varios métodos que la clase debe implementar" do
    un_trait = Trait.new_from_block { requires :m1, :m2; def m3 = 30 }

    una_clase = Class.new
    una_clase.define_method(:m1) { 10 }
    una_clase.define_method(:m2) { 20 }
    una_clase.uses(un_trait)

    expect(una_clase.new.m3).to eq(30)
  end

  specify "no implementar uno de los métodos requeridos lanza una excepción" do
    un_trait = Trait.new_from_block { requires :m1, :m2 }

    una_clase = Class.new
    una_clase.define_method(:m1) { 10 }
    una_clase.uses(un_trait)

    expect { una_clase.new.m2 }.to raise_error(MetodoRequerido)
  end

  specify "no implementar ninguno de los métodos requeridos lanza una excepción por cada uno" do
    un_trait = Trait.new_from_block { requires :m1, :m2 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect { una_clase.new.m1 }.to raise_error(MetodoRequerido)
    expect { una_clase.new.m2 }.to raise_error(MetodoRequerido)
  end

  specify "no implementar un método requerido no lanza excepción si no se lo llama" do
    un_trait = Trait.new_from_block { requires :m1, :m2 }

    una_clase = Class.new
    una_clase.define_method(:m1) { 10 }
    una_clase.uses(un_trait)

    expect { una_clase.new.m1 }.not_to raise_error
  end

  #Herencia
  specify "el método requerido puede estar definido en la clase padre" do
    un_trait = Trait.new_from_block { requires :m1; def m2 = m1 + 10 }

    una_clase_padre = Class.new
    una_clase_padre.define_method(:m1) { 10 }

    una_clase = Class.new(una_clase_padre)
    una_clase.uses(un_trait)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
  end


end
