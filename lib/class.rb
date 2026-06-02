require "excepciones"
class Class
  def uses(un_trait)
    raise NoEsUnTrait, "#{un_trait} no es un trait" unless un_trait.is_a?(Trait)
    raise TraitConConflictos, "Conflicto en: #{un_trait.conflictivos}" if un_trait.conflictivos.any?
    metodos_instalados = un_trait.apply_to(self)

    @traits ||= []
    @traits << un_trait

    @trait_methods ||= []
    @trait_methods.concat(metodos_instalados)
  end

  def traits
    @traits ||= []
  end

  def uses?(un_trait)
    traits.include? un_trait
  end

  def trait_methods
    @trait_methods ||= []
  end
end
