# Changelog

## Release 26.0.0
Wednesday, November 4th
* **Breaking** Actualiza a Ruby 4.0.9 y Sinatra 4.2.1 (Rack 3 + Puma). El servidor requiere Ruby 4.0
* **Breaking** Las posiciones (`o`) apuntan a la palabra limpia, sin la puntuación inicial, y ya no se desfasan con espacios múltiples o saltos de línea: `texto[o, l]` es la palabra marcada
* **Breaking** Los nombres de headers de respuesta salen en minúscula (Rack 3)
* **Fix** Las sugerencias con tilde ya no salen corruptas y las palabras con tilde bien escritas ya no se marcan como error. El encoding de aspell ya no depende del locale
* **Fix** La puntuación repetida (`Bueno...`, `¡¡Hola!!`) ya no se marca como error
* **Update** Reemplaza `sinatra-cross_origin` por headers CORS propios con los mismos valores
* **New** Entorno de desarrollo con Podman compose en el puerto 3019 y Dev Container para Ruby LSP en VS Code
* **New** Suite de tests con Minitest

## Hotfix 17.0.4
Monday, May 15th
* **Fix** [Agrega método options](https://github.com/5rabbits/speller/pull/3)

## Hotfix 17.0.3
Tuesday,  May 2nd
* **Fix** Force encoding ISO-8859-1

## Hotfix 17.0.2
Monday, April 24th
* **Fix** [Corrige encoding de las sugerencias](https://github.com/5rabbits/speller/pull/2)

## Hotfix 17.0.1
Tuesday, April 11th
* **Fix** [Corrige llave para diccionario portugues](https://github.com/5rabbits/speller/pull/1)
