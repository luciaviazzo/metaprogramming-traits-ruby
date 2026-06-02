class TraitModule < Module
  def requires(*metodos)
    @requeridos ||= []
    @requeridos.concat(metodos)
    metodos.each do |metodo|
      define_method(metodo) { super() rescue raise MetodoRequerido, "Falta implementar el método: #{metodo}" }
    end
  end

  def requeridos
    @requeridos || []
  end

  def uses(otro_trait)
    @traits_usados ||= []
    @traits_usados << otro_trait
  end

  def traits_usados
    @traits_usados || []
  end
end
