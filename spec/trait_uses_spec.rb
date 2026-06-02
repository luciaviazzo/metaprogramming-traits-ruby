require "rspec"
require "trait"

describe "Trait - Uses" do
  specify "un trait puede usar otro trait y la clase accede a sus métodos" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; 20; end
    end

    una_clase = Class.new
    una_clase.uses(otro_trait)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
  end

  specify "un trait puede usar otro trait que también usa otro trait" do
    trait_a = Trait.new_from_block do
      def m1; 10; end
    end

    trait_b = Trait.new_from_block do
      uses trait_a
      def m2; 20; end
    end

    trait_c = Trait.new_from_block do
      uses trait_b
      def m3; 30; end
    end

    una_clase = Class.new
    una_clase.uses(trait_c)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
    expect(una_clase.new.m3).to eq(30)
  end

  specify "un trait puede usar los métodos del trait que usa" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; m1 * 2; end
    end

    una_clase = Class.new
    una_clase.uses(otro_trait)

    expect(una_clase.new.m2).to eq(20)
  end

  specify "si el trait usa otro trait con un mismo método gana sobre su jerarquía" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m1; 20; end
    end

    una_clase = Class.new
    una_clase.uses(otro_trait)

    expect(una_clase.new.m1).to eq(20)
  end

  specify "un trait puede requerir métodos que son satisfechos por la clase cuando usa otro trait" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      requires :m3
      uses un_trait
      def m2; 20 end
    end

    una_clase = Class.new
    una_clase.define_method(:m3) { 30 }
    una_clase.uses(otro_trait)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
    expect(una_clase.new.m3).to eq(30)
  end

  specify "un trait puede usar otro trait que tiene métodos requeridos satisfechos por la clase" do
    un_trait = Trait.new_from_block do
      requires :m3
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; 20 end
    end

    una_clase = Class.new
    una_clase.define_method(:m3) { 30 }
    una_clase.uses(otro_trait)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
    expect(una_clase.new.m3).to eq(30)
  end

  specify "un trait satisface los requerimientos del trait que usa" do
    un_trait = Trait.new_from_block do
      requires :m2
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; 20 end
    end

    una_clase = Class.new
    una_clase.uses(otro_trait)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
  end

  specify "un trait usado satisface los requerimientos del trait que lo usa" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      requires :m1
      uses un_trait
      def m2; 20 end
    end

    una_clase = Class.new
    una_clase.uses(otro_trait)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
  end

  specify "un trait puede usar múltiples traits" do
    trait_a = Trait.new_from_block do
      def m1; 10; end
    end

    trait_b = Trait.new_from_block do
      def m2; 20; end
    end

    trait_c = Trait.new_from_block do
      uses trait_a
      uses trait_b
      def m3; 30; end
    end

    una_clase = Class.new
    una_clase.uses(trait_c)

    expect(una_clase.new.m1).to eq(10)
    expect(una_clase.new.m2).to eq(20)
    expect(una_clase.new.m3).to eq(30)
  end

  specify "si dos traits usados definen el mismo método, gana el primero" do
    trait_a = Trait.new_from_block { def m1 = 10 }
    trait_b = Trait.new_from_block { def m1 = 20 }
    trait_c = Trait.new_from_block do
      uses trait_a
      uses trait_b
    end

    una_clase = Class.new
    una_clase.uses(trait_c)
    expect(una_clase.new.m1).to eq(10)
  end

  specify "instance_methods(false) solo incluye los métodos propios" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; 20; end
    end

    expect(otro_trait.instance_methods(false)).not_to include :m1
    expect(otro_trait.instance_methods(false)).to include :m2
  end

  specify "instance_methods incluye todos los métodos" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; 20; end
    end

    expect(otro_trait.instance_methods).to include :m1
    expect(otro_trait.instance_methods).to include :m2
  end

  specify "instance_method devuelve UnboundMethod" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; 20; end
    end

    expect(otro_trait.instance_method(:m2)).to be_a(UnboundMethod)
    expect(otro_trait.instance_method(:m1)).to be_a(UnboundMethod)
  end

  specify "required_methods es vacío si se satisfacen los requerimientos" do
    un_trait = Trait.new_from_block do
      requires :m2
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      requires :m1
      def m2; 20 end
    end

    expect(otro_trait.required_methods).to be_empty  # Esto fue una decisión de diseño
  end

  specify "required_methods tiene los métodos requeridos no satisfechos" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      requires :m3
      def m2; 20 end
    end

    expect(otro_trait.required_methods).to include :m3
  end

  specify "requires? devuelve false para métodos requeridos ya satisfechos" do
    un_trait = Trait.new_from_block do
      requires :m2
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      requires :m1
      def m2; 20 end
    end

    expect(otro_trait.requires? :m2).to be false
    expect(otro_trait.requires? :m1).to be false
    # Ambos: Fue una decisión de diseño
  end

  specify "requires? solo devuelve true para un métodos requeridos no satisfecho" do
    un_trait = Trait.new_from_block do
      requires :m1
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
    end

    expect(otro_trait.requires? :m1).to be true
  end

  specify "method_defined? devuelve true solo para los métodos definidos" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; 20 end
    end

    expect(otro_trait.method_defined? :m1).to be true
    expect(otro_trait.method_defined? :m2).to be true
  end

  specify "la clase gana sobre el trait cuando ambos definen el mismo método a través de uses" do
    un_trait = Trait.new_from_block do
      def m1; 10 end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
    end

    una_clase = Class.new
    una_clase.define_method(:m1) { 20 }
    una_clase.uses(otro_trait)

    expect(una_clase.new.m1).to eq(20)
  end

  specify "instance_method devuelve nil para métodos no definidos" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
    end

    otro_trait = Trait.new_from_block do
      uses un_trait
      def m2; 20; end
    end

    expect(otro_trait.instance_method(:m3)).to be_nil
  end
end
