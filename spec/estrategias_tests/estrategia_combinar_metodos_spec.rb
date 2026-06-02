require "rspec"
require "trait"
require "estrategia"

describe "TraitEstrategiaCombinarMetodos" do
  specify "al resolver un conflicto, se combinan los metodos de ambos traits" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    una_clase = Class.new
    una_estrategia = Estrategia.combinar_metodos(un_trait, otro_trait)
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))

    expect(una_clase.new.m1).to eq(20)
  end

  specify "se ejecutan ambos métodos en orden y se preservan efectos secundarios" do
    trait_izq = Trait.new_from_block do
      def m1(valor)
        @resultado ||= []
        @resultado << "izq:#{valor}"
      end
    end

    trait_der = Trait.new_from_block do
      def m1(valor)
        @resultado ||= []
        @resultado << "der:#{valor}"
        "fin"
      end
    end

    una_clase = Class.new
    una_estrategia = Estrategia.combinar_metodos(trait_izq, trait_der)

    trait_compuesto = (trait_izq + trait_der).resolver_conflicto(:m1, una_estrategia)
    una_clase.uses trait_compuesto

    instancia = una_clase.new
    retorno = instancia.m1("test")

    expect(instancia.instance_variable_get(:@resultado)).to eq(["izq:test", "der:test"])
    expect(retorno).to eq("fin")
  end

  specify "al resolver un conflicto, se ejecutan los métodos de ambos traits en orden" do
    un_trait = Trait.new_from_block do
      def m1; @r ||= []; @r << 1; end
    end

    otro_trait = Trait.new_from_block do
      def m1; @r ||= []; @r << 2; end
    end

    una_clase = Class.new
    una_estrategia = Estrategia.combinar_metodos(un_trait, otro_trait)
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))

    instancia = una_clase.new
    instancia.m1
    expect(instancia.instance_variable_get(:@r)).to eq([1, 2])
  end

  specify "al resolver un conflicto, los argumentos se propagan a ambos métodos" do
    un_trait = Trait.new_from_block do
      def m1(v); @r ||= 0; @r += v; end
    end

    otro_trait = Trait.new_from_block do
      def m1(v); @r ||= 0; @r *= v; end
    end

    una_clase = Class.new
    una_estrategia = Estrategia.combinar_metodos(un_trait, otro_trait)
    una_clase.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))

    instancia = una_clase.new
    instancia.m1(10)
    expect(instancia.instance_variable_get(:@r)).to eq(100)
  end

  specify "al resolver un conflicto, los otros métodos y conflictos se mantienen" do
    un_trait = Trait.new_from_block do
      def m1; 10; end
      def m2; 30; end
    end

    otro_trait = Trait.new_from_block do
      def m1; 20; end
      def m2; 40; end
      def m3; 50; end
    end

    una_clase = Class.new
    una_estrategia = Estrategia.combinar_metodos(un_trait, otro_trait)
    un_trait_conflictivo = (un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia)

    expect(un_trait_conflictivo.conflictivos).not_to be_empty
    expect { una_clase.uses(un_trait_conflictivo) }.to raise_error(TraitConConflictos)
  end

  specify "se pueden combinar múltiples conflictos con resultados secuenciales" do
    un_trait = Trait.new_from_block do
      def m1; @r ||= ""; @r += "a"; end
      def m2; @r ||= ""; @r += "c"; end
    end

    otro_trait = Trait.new_from_block do
      def m1; @r ||= ""; @r += "b"; end
      def m2; @r ||= ""; @r += "d"; end
    end

    una_clase = Class.new
    un_trait_conflictivo = un_trait + otro_trait
    una_clase.uses(
      un_trait_conflictivo
        .resolver_conflictos(
          m1: Estrategia.combinar_metodos(un_trait, otro_trait),
          m2: Estrategia.combinar_metodos(un_trait, otro_trait)
        )
    )

    instancia = una_clase.new
    instancia.m1
    instancia.m2
    expect(instancia.instance_variable_get(:@r)).to eq("abcd")
  end

  specify "resolver un conflicto de forma secuencial mantiene la conmutatividad del resultado" do
    un_trait = Trait.new_from_block do
      def m1; @r ||= []; @r << "izq"; end
    end

    otro_trait = Trait.new_from_block do
      def m1; @r ||= []; @r << "der"; end
    end

    una_estrategia = Estrategia.combinar_metodos(un_trait, otro_trait)

    clase_izq = Class.new
    clase_izq.uses((un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia))

    clase_der = Class.new
    clase_der.uses((otro_trait + un_trait).resolver_conflicto(:m1, una_estrategia))

    instancia_izq = clase_izq.new
    instancia_izq.m1
    instancia_der = clase_der.new
    instancia_der.m1

    expect(instancia_izq.instance_variable_get(:@r)).to eq(["izq", "der"])
    expect(instancia_der.instance_variable_get(:@r)).to eq(["izq", "der"])
  end

  specify "lanza una excepción si el trait elegido no tiene el método conflictivo" do
    un_trait = Trait.new_from_block { def m1 = 10 }
    otro_trait = Trait.new_from_block { def m1 = 20 }

    un_trait_sin_relacion = Trait.new_from_block do
      def m2; 30; end
    end

    una_estrategia = Estrategia.combinar_metodos(un_trait_sin_relacion, otro_trait)

    expect do
      (un_trait + otro_trait).resolver_conflicto(:m1, una_estrategia)
    end.to raise_error(NoMethodError)
  end
end
