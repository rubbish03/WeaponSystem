# WeaponSystem

Sistema de armas personalizado para Roblox basado en el WeaponsSystem, con mejoras para camara, control movil, velocidad tactica y compatibilidad con sistemas externos como el exoesqueleto.

## Historial de mejoras

### Mejoras en WeaponsSystem.luau (Core)

**Inyeccion de la funcion `TriggerFire`:** Abrimos y expusimos esta funcion en el modulo principal para permitir que scripts locales externos puedan llamar al comando de disparo. Esto fue vital para construir una interfaz de tiro personalizada para celular sin depender de los botones predeterminados de Roblox.

**Gestion dinamica de `WalkSpeed`:** Se modifico la forma en la que el sistema penaliza o altera la velocidad del jugador al equipar o apuntar un arma, integrando compatibilidad para respetar factores externos del juego, como los multiplicadores de velocidad cuando el jugador trae puesto un exoesqueleto.

**Anti fuego aliado:** Se agrego una validacion de equipos antes de aplicar dano entre jugadores. Si dos jugadores estan en el mismo equipo, el disparo no aplica dano; si estan en equipos distintos, el dano se permite. Esto permite usar el mismo WeaponsSystem tanto para modos por equipo como para modos FFA donde el game loop asigna equipos separados.

### Mejoras en ShoulderCamera.luau (Camara)

**Fix de agresividad en GUIs:** Se parcho el conflicto donde la camara se volvia inestable, se arrastraba o disparaba la sensibilidad cuando el jugador interactuaba con interfaces en pantalla. Ahora la camara cede el control limpiamente cuando el input cae sobre una GUI.

**Rotacion procedural del torso:** Se implementaron ajustes matematicos para lograr animaciones mas naturales. Ahora el torso del personaje acompana el movimiento de la camara de forma procedural e inmersiva, reduciendo la rigidez del avatar al apuntar.
