# Quest Master CLI - Terminal Edition

Version de consola para testing inmediato de la logica del juego.

## Como Ejecutar

```bash
# Desde la raiz del proyecto:
dart run bin/quest_master_cli.dart
```

## Comandos Disponibles

| Comando | Alias | Descripcion |
|---------|-------|-------------|
| `help` | `ayuda`, `?` | Muestra todos los comandos |
| `inv` | `inventario`, `i` | Muestra el inventario |
| `stats` | `estado` | Muestra estadisticas del personaje |
| `equip <nombre>` | `equipar` | Equipar/desequipar un item |
| `mision <texto>` | `quest` | Ver/cambiar mision principal |
| `resumir` | | Forzar resumen de historia |
| `contexto` | `context` | Ver el prompt que se envia a la IA |
| `save <slot>` | `guardar` | Guardar partida (default: autosave) |
| `load <slot>` | `cargar` | Cargar partida guardada |
| `debug items` | | Darte items de vision para testing |
| `quit` | `salir`, `exit` | Salir del juego |

Cualquier otro texto se envia como accion libre del jugador.

## Acciones de Ejemplo

```
> camino hacia el norte
> examino los arboles
> ataco al goblin con mi espada
> hablo con el mercader
> busco tesoros en la cueva
```

## Sistema de Vision (Testing)

Para probar el sistema de stats ocultos/revelados:

1. Escribe `stats` → Veras solo descripciones narrativas
2. Escribe `debug items` → Te da items de vision
3. Escribe `equip ojo` → Equipa el Ojo de Verdad
4. Escribe `stats` → Ahora veras numeros y barras!

## Diferencias con la App Movil

| Aspecto | App Movil (Flutter) | CLI (Terminal) |
|---------|-------------------|----------------|
| UI | Widgets, burbujas de chat | Texto ASCII formateado |
| Input | TextField con boton | stdin readline |
| Tema | Material Design dark | ANSI colors |
| Persistencia | path_provider + JSON | Archivos locales cli_saves/ |
| IA | Configurable (Mock/Ollama) | Solo MockAIService |

## Estructura

```
bin/
├── quest_master_cli.dart   # Game loop principal
├── cli_ui.dart             # Formateo de terminal
└── CLI_README.md           # Esta documentacion
```

## Escenarios de Test

### Test 1: Flujo basico
```
> camino al norte
> examino alrededor
> busco algo util
> inv
```

### Test 2: Sistema de vision
```
> debug items
> stats         (sin numeros)
> equip ojo
> stats         (con numeros!)
> inv           (sin propiedades)
> equip gafas
> inv           (con propiedades!)
```

### Test 3: Contexto IA
```
> exploro la cueva
> ataco al monstruo
> contexto      (ver prompt completo)
> resumir       (comprimir historia)
> contexto      (ver prompt mas corto)
```

### Test 4: Save/Load
```
> save mi_partida
> quit
$ dart run bin/quest_master_cli.dart
> load mi_partida
```
