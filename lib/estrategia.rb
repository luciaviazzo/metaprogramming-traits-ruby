class Estrategia
  def self.new_from_block(&bloque)
    new(bloque)
  end

  def initialize(bloque = nil)
    @bloque = bloque
  end

  def self.elegir_trait(trait_elegido)
    new_from_block do |metodos_conflictivos|
      metodo_a_usar = encontrar_metodo_de(trait_elegido, metodos_conflictivos)

      proc do |*args, &block|
        metodo_a_usar.bind(self).call(*args, &block)
      end
    end
  end

  def self.combinar_metodos(trait_izq, trait_der)
    new_from_block do |metodos_conflictivos|
      metodo_izq = encontrar_metodo_de(trait_izq, metodos_conflictivos)
      metodo_der = encontrar_metodo_de(trait_der, metodos_conflictivos)

      proc do |*args, &block|
        metodo_izq.bind(self).call(*args, &block)
        metodo_der.bind(self).call(*args, &block)
      end
    end
  end

  def self.reduce(valor_inicial, &bloque)
    new_from_block do |metodos_conflictivos|
      raise NoMethodError, "No hay conflictos para ese método" if metodos_conflictivos.nil?

      proc do |*args, &block|
        metodos_conflictivos.map { |m| m.bind(self).call(*args, &block) }
                            .reduce(valor_inicial, &bloque)
      end
    end
  end

  def resolver(selector, metodos_conflictivos)
    raise NotImplementedError, "Implementar en subclase" if @bloque.nil?

    nuevo_proc = @bloque.call(metodos_conflictivos)
    raise TypeError, "El bloque debe devolver un proc" unless nuevo_proc.is_a?(Proc)

    modulo_temporal = Module.new
    modulo_temporal.define_method(selector, nuevo_proc)
    modulo_temporal.instance_method(selector)
  end

  private
  def self.encontrar_metodo_de(trait, metodos_conflictivos)
    metodos_conflictivos.find(proc do
      raise NoMethodError, "#{trait} no tiene el método"
    end) { |m| trait.metodos.value?(m) }
  end
end
