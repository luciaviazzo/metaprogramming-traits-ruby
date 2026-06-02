# Metaprogramming Traits Ruby

Implementación de un sistema de Traits en Ruby desarrollada para la materia Programación con Objetos 3.

## Descripción

Este proyecto implementa un mecanismo de composición de comportamiento basado en Traits utilizando técnicas de metaprogramación en Ruby.

Los Traits permiten reutilizar comportamiento entre clases de una forma más flexible que la herencia tradicional.

Además de la implementación básica, el proyecto incluye operaciones para combinar Traits, resolver conflictos entre métodos, definir requerimientos, crear estrategias de resolución configurables y realizar reflexión sobre los Traits definidos.

## Funcionalidades

- Definición de Traits
- Uso de Traits en clases
- Métodos requeridos (`requires`)
- Composición de Traits
- Detección de conflictos
- Exclusión de métodos
- Alias de métodos
- Estrategias predefinidas de resolución de conflictos
- Definición de estrategias personalizadas de resolución de conflictos
- Reflexión e introspección
- Soporte para pruebas automatizadas

## Tecnologías

- Ruby
- RSpec
- RuboCop

## Instalación

Clonar el repositorio:

```bash
git clone https://github.com/TU_USUARIO/metaprogramming-traits-ruby.git
cd metaprogramming-traits-ruby
```

Instalar dependencias:

```bash
bundle install
```

## Ejecutar los tests

```bash
bundle exec rspec
```

## Análisis de código

```bash
bundle exec rubocop
```

## Ejemplos de uso

### Definición y composición de Traits

```ruby
trait Atacante do
  def ataque
    10
  end
end

trait Defensor do
  def defensa
    20
  end
end

class Guerrero
  uses Atacante + Defensor
end

guerrero = Guerrero.new

guerrero.ataque
# => 10

guerrero.defensa
# => 20
```

### Traits con métodos requeridos

```ruby
trait Humano do
  requires :nombre, :apellido

  def saludo
    "Hola, soy #{nombre} #{apellido}"
  end
end

class Ciudadano
  uses Humano

  def nombre
    "Juan"
  end

  def apellido
    "Pérez"
  end
end

Ciudadano.new.saludo
# => "Hola, soy Juan Pérez"
```

### Estrategias personalizadas de resolución de conflictos

Además de las estrategias provistas por la herramienta, es posible definir estrategias personalizadas para determinar cómo resolver conflictos entre métodos con el mismo nombre.

```ruby
mi_estrategia = Estrategia.new_from_block do |metodos_conflictivos|
  # Lógica definida por el usuario para combinar,
  # seleccionar o ejecutar los métodos en conflicto.
end

un_trait_compuesto =
  (un_trait + otro_trait)
    .resolver_conflicto(:m1, mi_estrategia)
```

Las estrategias reciben acceso a los métodos conflictivos y pueden implementar cualquier política de resolución, como:

- Seleccionar uno de los métodos.
- Ejecutar todos los métodos.
- Combinar sus resultados mediante una reducción.
- Definir criterios completamente personalizados.

## Conceptos aplicados

Durante el desarrollo se trabajó con:

- Programación Orientada a Objetos
- Metaprogramación
- Reflexión e introspección
- Composición de comportamiento
- Diseño e implementación de una DSL para la definición y composición de Traits
- Resolución de conflictos mediante estrategias configurables
- Desarrollo guiado por pruebas (TDD)

## Trabajo en equipo

Este proyecto fue desarrollado por un equipo de 4 integrantes.

La implementación requirió diseñar una solución extensible, discutir decisiones de arquitectura, resolver desafíos de metaprogramación y coordinar el desarrollo mediante pruebas automatizadas y revisiones de código.

La experiencia permitió fortalecer tanto habilidades técnicas como competencias de trabajo colaborativo en el desarrollo de software.

## Contexto académico

Proyecto realizado para la materia Programación con Objetos 3.

El objetivo fue diseñar e implementar una herramienta de programación utilizando las capacidades metaprogramáticas de Ruby, pasando de utilizar un lenguaje a extenderlo mediante nuevas abstracciones.

Además de los desafíos técnicos, el proyecto implicó trabajo colaborativo en el diseño, implementación y validación de la solución mediante pruebas automatizadas.
