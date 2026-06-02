# Plantilla de Proyecto Ruby para Objetos 3 (UNQ)

## Setup

La primera vez que clonen el repositorio deberan instalar las dependencias que ya tenemos definidas en Gemfile (rspec), para esto tienen que tener instalado `ruby` y `bundler`.

Verificar que tengo Ruby:

```bash
$ ruby -v
# => ruby 3.4.9 (2026-03-11 revision 76cca827ab) +PRISM [x86_64-linux]
```

Verificar que tengo Bundler:

```bash
$ bundle -v
# => Bundler version 2.6.9
```

Ahora sí, instalamos con:

```bash
$ bundle install
```

## Ejecutar las pruebas

Desde el IDE: haciendo click derecho en la carpeta `spec` y usando la opción "Run all **specs** in ...".

Desde una terminal:
```bash
$ bundle exec rspec
```

## Ejecutar el linter

Para verificar que el código sigue las convenciones de estilo de Ruby:

```bash
$ bundle exec rubocop
```

Para corregir automáticamente lo que el linter puede resolver solo:

```bash
$ bundle exec rubocop -a
```
