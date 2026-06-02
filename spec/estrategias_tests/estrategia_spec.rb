require "rspec"
require "trait"
require "estrategia"

describe Estrategia do
  specify "se puede crear una estrategia" do
    una_estrategia = Estrategia.new_from_block do |_|
      proc { 42 }
    end

    expect(una_estrategia).to be_a(Estrategia)
  end

  specify "lanza error si la estrategia no devuelve un proc" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    mi_estrategia = Estrategia.new_from_block do |_|
      "no soy un proc"
    end

    expect do
      (un_trait + otro_trait).resolver_conflicto(:m1, mi_estrategia)
    end.to raise_error(TypeError)
  end

  specify "lanza error si se llama resolver sin bloque" do
    una_estrategia = Estrategia.new

    expect do
      una_estrategia.resolver(:m1, [])
    end.to raise_error(NotImplementedError)
  end

  specify "la estrategia recibe exactamente los métodos en conflicto" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    metodos_recibidos = nil
    mi_estrategia = Estrategia.new_from_block do |metodos_conflictivos|
      metodos_recibidos = metodos_conflictivos
      proc {}
    end

    (un_trait + otro_trait).resolver_conflicto(:m1, mi_estrategia)

    expect(metodos_recibidos.size).to eq(2)
    expect(metodos_recibidos).to all(be_a(UnboundMethod))
  end

  specify "el usuario puede definir su propia estrategia" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    mi_estrategia = Estrategia.new_from_block do |metodos_conflictivos|
      proc do |*args|
        metodos_conflictivos.first.bind(self).call(*args)
      end
    end

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, mi_estrategia))

    expect(una_clase.new.m1).to eq(10)
  end

  specify "la estrategia personalizada puede elegir el último método" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    mi_estrategia = Estrategia.new_from_block do |metodos_conflictivos|
      proc do |*args|
        metodos_conflictivos.last.bind(self).call(*args)
      end
    end

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, mi_estrategia))

    expect(una_clase.new.m1).to eq(20)
  end


  specify "la estrategia puede acceder al estado de la instancia con self" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    mi_estrategia = Estrategia.new_from_block do |metodos_conflictivos|
      proc do |*args|
        @resultado = metodos_conflictivos.first.bind(self).call(*args)
      end
    end

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, mi_estrategia))

    instancia = una_clase.new
    instancia.m1
    expect(instancia.instance_variable_get(:@resultado)).to eq(10)
  end

  specify "la estrategia funciona con argumentos" do
    un_trait = Trait.new_from_block do
      def m1(v); v * 2; end
    end

    otro_trait = Trait.new_from_block do
      def m1(v); v * 3; end
    end

    mi_estrategia = Estrategia.new_from_block do |metodos_conflictivos|
      proc do |*args|
        metodos_conflictivos.first.bind(self).call(*args)
      end
    end

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, mi_estrategia))

    expect(una_clase.new.m1(5)).to eq(10)
  end

  specify "la estrategia funciona con bloques" do
    un_trait = Trait.new_from_block do
      def m1; yield 10; end
    end

    otro_trait = Trait.new_from_block do
      def m1; yield 20; end
    end

    mi_estrategia = Estrategia.new_from_block do |metodos_conflictivos|
      proc do |*args, &block|
        metodos_conflictivos.first.bind(self).call(*args, &block)
      end
    end

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, mi_estrategia))

    expect(una_clase.new.m1 { |v| v * 2 }).to eq(20)
  end

  specify "la estrategia personalizada puede hacer lógica compleja" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    mi_estrategia = Estrategia.new_from_block do |metodos_conflictivos|
      proc do |*args|
        resultados = metodos_conflictivos.map { |m| m.bind(self).call(*args) }
        resultados.sum / resultados.size
      end
    end

    una_clase = Class.new
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, mi_estrategia))

    expect(una_clase.new.m1).to eq(15)
  end

  specify "resolver_conflictos resuelve múltiples conflictos de una vez" do
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
