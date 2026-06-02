# Trait
require "trait_module"
require "class"
require "excepciones"

class Trait
  def self.new_from_block(&definicion_del_trait)
    un_modulo = TraitModule.new
    un_modulo.module_exec(&definicion_del_trait)
    metodos_extraidos = un_modulo.instance_methods(false).to_h do |selector|
      [selector, un_modulo.instance_method(selector)]
    end
    requeridos = un_modulo.requeridos

    new(metodos_extraidos, requeridos, un_modulo)
  end

  def initialize(metodos, requeridos, un_modulo, conflictivos = {})
    @metodos = metodos
    @requeridos = requeridos
    @suscriptores = []
    @origen_metodos = {}
    @conflictivos = conflictivos
    @operaciones_relacionadas = []
    registrar_origen(@metodos.keys, self)
    procesar_traits_usados(un_modulo)
  end

  def apply_to(una_clase)
    @suscriptores << una_clase
    metodos_a_instalar = @metodos.keys - una_clase.instance_methods
    instalar_metodos_en(una_clase, @metodos.slice(*metodos_a_instalar))
    metodos_a_instalar
  end

  def +(otro_trait)
    raise TypeError, "Solo puedes sumar otro Trait" unless otro_trait.is_a?(Trait)

    nuevos_conflictivos = conflicto_entre(concretos & otro_trait.concretos, otro_trait)
    nuevos_metodos = combinar_metodos(otro_trait, nuevos_conflictivos.keys)
    nuevos_requeridos = (@requeridos + otro_trait.requeridos) - concretos - otro_trait.concretos

    trait_suma = Trait.new(nuevos_metodos, nuevos_requeridos.uniq, TraitModule.new, nuevos_conflictivos)
    registrar_operacion(trait_suma, otro_trait)
    trait_suma
  end

  def -(selectores)
    selectores = Array(selectores)
    validar_simbolos(selectores)
    nuevos_metodos = @metodos.reject { |selector, _| selectores.include?(selector) }
    nuevos_requeridos = @requeridos - selectores

    trait_resta = Trait.new(nuevos_metodos, nuevos_requeridos, TraitModule.new)
    registrar_operacion(trait_resta)
    trait_resta
  end

  def <<(aliases)
    raise TypeError, "Debe ser un hash" unless aliases.is_a?(Hash)

    nuevos_aliases = aliases.each_with_object({}) do |(original, nuevo), hash|
      validar_simbolos(original, nuevo)
      raise NoMethodError, "El trait no tiene el método #{original}" unless @metodos.key?(original)
      hash[nuevo] = @metodos[original]
    end

    trait_con_renombre = Trait.new(@metodos.merge(nuevos_aliases), @requeridos, TraitModule.new)
    registrar_operacion(trait_con_renombre)
    trait_con_renombre
  end

  def resolver_conflicto(selector, estrategia)
    metodos_en_conflicto = @conflictivos[selector]
    nuevo_metodo = estrategia.resolver(selector, metodos_en_conflicto)
    metodos_actualizados = @metodos.merge(selector => nuevo_metodo)
    conflictos_actualizados = @conflictivos.except(selector)
    Trait.new(metodos_actualizados, @requeridos, TraitModule.new, conflictos_actualizados)
  end

  def resolver_conflictos(**estrategias)
    trait_resuelto = self
    estrategias.each do |selector, estrategia|
      trait_resuelto = trait_resuelto.resolver_conflicto(selector, estrategia)
    end
    trait_resuelto
  end

  # -------- Reflexion --------
  def instance_methods(incluye_herencia = true)
    if incluye_herencia
      @metodos.keys
    else
      @origen_metodos.select { |_, origen| origen.equal?(self) }.keys
    end
  end

  def required_methods
    requeridos
  end

  def requires?(symbol)
    requeridos.include?(symbol)
  end

  def method_defined?(symbol)
    @metodos.key?(symbol)
  end

  def instance_method(symbol)
    @metodos[symbol]
  end

  def has_conflicts?
    conflictivos.any?
  end

  # -------- Modificación en tiempo de ejecución --------
  def define_method(selector, &block)
    un_modulo = TraitModule.new
    un_modulo.define_method(selector, &block)
    nuevo_metodo = un_modulo.instance_method(selector)
    @metodos[selector] = nuevo_metodo

    @suscriptores.each do |una_clase|
      metodos_a_instalar = metodos_a_instalar_en(una_clase) & [selector]
      una_clase.define_method(selector, &block) if metodos_a_instalar.any?
    end
    @operaciones_relacionadas.each { |un_trait| un_trait.define_method(selector, &block) }
  end

  def metodos_a_instalar_en(una_clase)
    @metodos.keys - una_clase.instance_methods
  end

  # -------- Getters --------
  def requeridos
    @requeridos
  end

  def metodos
    @metodos
  end

  def conflictivos
    @conflictivos
  end

  def operaciones_relacionadas
    @operaciones_relacionadas || []
  end

  # -------- Auxiliares --------
  private

  def procesar_traits_usados(modulo_temporal)
    modulo_temporal.traits_usados.each do |trait_usado|
      conflictos_con_trait_usado = conflicto_entre(concretos & trait_usado.concretos, trait_usado)
      trait_combinado = self + (trait_usado - conflictos_con_trait_usado.keys)
      @metodos = trait_combinado.metodos
      @requeridos = trait_combinado.requeridos
      @conflictivos = trait_combinado.conflictivos
      registrar_origen(trait_usado.instance_methods, trait_usado)
      trait_usado.operaciones_relacionadas << self
    end
  end

  def registrar_origen(metodos, origen)
    metodos.each do |selector|
      @origen_metodos[selector] = origen
    end
  end

  #Auxiliares de apply_to
  def instalar_metodos_en(una_clase, diccionario)
    diccionario.each do |selector, metodo|
      una_clase.define_method(selector, metodo)
    end
  end

  #Auxiliares de +
  def combinar_metodos(otro_trait, conflictos = nil)
    conflictos ||= conflicto_entre(concretos & otro_trait.concretos, otro_trait).keys

    metodos_a_agregar = otro_trait.metodos.reject do |selector, _|
      concretos.include?(selector) && !otro_trait.concretos.include?(selector)
    end

    @metodos.merge(metodos_a_agregar).except(*conflictos)
  end

  def registrar_operacion(trait_resultado, *otros_traits)
    @operaciones_relacionadas << trait_resultado
    otros_traits.each { |t| t.operaciones_relacionadas << trait_resultado }
  end

  #Otras
  def conflicto_entre(nombres_compartidos, otro_trait)
    mi_hash = @metodos
    su_hash = otro_trait.metodos
    nombres_compartidos
      .reject { |nombre| mi_hash[nombre] == su_hash[nombre] }
      .each_with_object({}) { |nombre, conflictos| conflictos[nombre] = [mi_hash[nombre], su_hash[nombre]] }
  end

  def validar_simbolos(*args)
    args.flatten.each do |arg|
      raise TypeError, "Debe ser un símbolo" unless arg.is_a?(Symbol)
    end
  end

  protected

  def concretos
    @metodos.keys - @requeridos
  end
end
