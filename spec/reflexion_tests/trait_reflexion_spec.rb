require "rspec"
require "trait"

describe "Trait - Reflexion" do
  # ----------- instance_methods -----------
  specify "instance_methods devuelve vacío para un trait vacío" do
    un_trait = Trait.new_from_block {}

    expect(un_trait.instance_methods).to be_empty
  end

  specify "instance_methods incluye los métodos definidos" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    expect(un_trait.instance_methods).to include :m1
  end

  specify "instance_methods incluye todos los métodos definidos" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
      def m2; 20 end
    end

    expect(un_trait.instance_methods).to include :m1
    expect(un_trait.instance_methods).to include :m2
  end

  specify "instance_methods(false) devuelve solo los métodos propios del trait" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { uses un_trait; def m2 = 20 }

    expect(otro_trait.instance_methods(false)).to include(:m2)
    expect(otro_trait.instance_methods(false)).not_to include(:m1)
  end

  # ----------- required_methods -----------
  specify "required_methods devuelve vacío para un trait vacío" do
    un_trait = Trait.new_from_block {}

    expect(un_trait.required_methods).to be_empty
  end

  specify "required_methods incluye los métodos requeridos" do
    un_trait = Trait.new_from_block { requires :m1 }

    expect(un_trait.required_methods).to include :m1
  end

  specify "required_methods incluye todos los métodos requeridos" do
    un_trait = Trait.new_from_block { requires :m1, :m2 }

    expect(un_trait.required_methods).to include :m1
    expect(un_trait.required_methods).to include :m2
  end

  # ----------- requires? -----------
  specify "requires? devuelve true para un método requerido" do
    un_trait = Trait.new_from_block { requires :m1 }

    expect(un_trait.requires? :m1).to be true
  end

  specify "requires? devuelve false para un método no requerido" do
    un_trait = Trait.new_from_block { requires :m1 }

    expect(un_trait.requires? :m2).to be false
  end

  # ----------- method_defined? -----------
  specify "method_defined? devuelve false para un método inexistente" do
    un_trait = Trait.new_from_block {}

    expect(un_trait.method_defined? :m1).to be false
  end

  specify "method_defined? devuelve true para un método definido" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    expect(un_trait.method_defined? :m1).to be true
  end

  specify "method_defined? devuelve false para un método no definido" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    expect(un_trait.method_defined? :m2).to be false
  end

  # ----------- instance_method -----------
  specify "instance_method devuelve nil para métodos no definidos" do
    un_trait = Trait.new_from_block {}
    expect(un_trait.instance_method :m1).to be_nil
  end

  specify "instance_method devuelve un UnboundMethod para métodos definidos" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    expect(un_trait.instance_method(:m1)).to be_a UnboundMethod
    expect(un_trait.instance_method(:m1).name).to eq :m1
  end

  # ----------- has_conflicts? -----------
  specify "has_conflicts? devuelve true ante métodos duplicados" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    expect((un_trait + otro_trait).has_conflicts?).to be true
  end

  specify "has_conflicts? devuelve false cuando no hay métodos duplicados" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    expect((un_trait + otro_trait).has_conflicts?).to be false
  end

  specify "has_conflicts? devuelve false para un trait sin operaciones" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    expect(un_trait.has_conflicts?).to be false
  end

  # ----------- traits? -----------
  specify "una clase sin traits devuelve una lista vacía" do
    una_clase = Class.new

    expect(una_clase.traits).to be_empty
  end

  specify "una clase conoce los traits que utiliza" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect(una_clase.traits).to include un_trait
  end

  specify "una clase puede utilizar múltiples traits" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(un_trait)
    una_clase.uses(otro_trait)

    expect(una_clase.traits).to include un_trait
    expect(una_clase.traits).to include otro_trait
  end

  specify "una clase puede utilizar una composición de traits" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_suma = un_trait + otro_trait
    una_clase.uses(una_suma)

    expect(una_clase.traits).to include una_suma
  end

  specify "una clase hereda los traits de su padre" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    clase_padre = Class.new
    clase_padre.uses(un_trait)

    clase_hija = Class.new(clase_padre)

    expect(clase_hija.traits).not_to include(un_trait)
  end
  # Preguntar si es neceario hacer: un_trait + otro_trait = [un_trait, otro_trait]

  # ----------- uses? -----------
  specify "uses? devuelve true para un trait utilizado" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect(una_clase.uses?(un_trait)).to be true
  end

  specify "uses? devuelve false para un trait no utilizad" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    expect(una_clase.uses?(un_trait)).to be false
  end

  specify "uses? devuelve true para un trait utilizado entre varios" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m2 = 20 }

    una_clase = Class.new
    una_clase.uses(otro_trait)
    una_clase.uses(un_trait)

    expect(una_clase.uses?(un_trait)).to be true
  end

  # ----------- traits_methods -----------
  specify "trait_methods devuelve vacío para una clase sin traits" do
    una_clase = Class.new
    expect(una_clase.trait_methods).to be_empty
  end

  specify "trait_methods incluye los métodos provenientes de traits" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect(una_clase.trait_methods).to include :m1
  end

  specify "trait_methods incluye todos los métodos provenientes de traits" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
      def m2; 20 end
    end

    una_clase = Class.new
    una_clase.uses(un_trait)

    expect(una_clase.trait_methods).to include :m1
    expect(una_clase.trait_methods).to include :m2
  end

  specify "trait_methods incluye métodos provenientes de múltiples traits" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
      def m2; 20 end
    end

    otro_trait = Trait.new_from_block { def m3 = 30 }

    una_clase = Class.new
    una_clase.uses(un_trait)
    una_clase.uses(otro_trait)

    expect(una_clase.trait_methods).to include :m1
    expect(una_clase.trait_methods).to include :m2
    expect(una_clase.trait_methods).to include :m3
  end

  specify "trait_methods incluye solo los métodos de los traits propios" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
      def m2; 20 end
    end
    otro_trait = Trait.new_from_block { def m3 = 30 }

    una_clase_padre = Class.new
    una_clase_padre.uses(otro_trait)

    una_clase = Class.new(una_clase_padre)
    una_clase.uses(un_trait)

    expect(una_clase.trait_methods).to include :m1
    expect(una_clase.trait_methods).to include :m2
  end

  specify "una clase reconoce los metodos propios como metodos de traits" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new do
      def m2; 20 end
    end

    una_clase.uses(un_trait)
    expect(una_clase.trait_methods).to include :m1
  end

  specify "una clase que define un metodo con el mismo nombre que el metodo de su trait, no lo reconoce como metodo de traits" do
    un_trait = Trait.new_from_block { def m1 = 10 }

    una_clase = Class.new do
      def m1; 99 end
    end

    una_clase.uses(un_trait)

    expect(una_clase.trait_methods).to be_empty
  end

  # trait_methods(bool) para indicar si queremos solo los metodos de los traits de la clase o tambien lo de la/s clase padre
end
