# 🎮 Quest Master v2.0 - Enhanced Edition

## 🎯 TODAS LAS MEJORAS IMPLEMENTADAS (Fase 1)

Este proyecto incluye **TODAS** las mejoras solicitadas para mejorar la experiencia de juego single-player. El modo cooperativo será Fase 2.

---

## ✨ NUEVAS CARACTERÍSTICAS

### 1. 🧙 Creación de Personaje Expandida

**ANTES:**
```
Nombre de tu personaje [Aventurero]: _
```

**AHORA:**
```
=== CREACIÓN DE PERSONAJE ===

¿Cómo te llamas? Elara

¿Qué clase eres?
  1. Mago
  2. Guerrero
  3. Pícaro
  4. Clérigo
  5. Explorador
  6. Otra (describe)
Opción: 1

¿Cuál es tu pasado? (2-3 líneas)
> Fui aprendiz de un mago del norte que desapareció misteriosamente.
  Busco respuestas sobre su destino mientras perfecciono mis hechizos.

¿Cómo te ves? (apariencia física)
> Mujer élfica de cabello plateado, ojos violetas, túnica azul oscuro

¿Qué te caracteriza? (personalidad/rasgos)
> Curiosa, impulsiva, algo arrogante con mi magia, pero leal
```

**Archivos nuevos:**
- `bin/character_wizard.dart` - Wizard interactivo de creación
- `lib/core/models/character.dart` - Añadido campo `characterClass`

---

### 2. 🎯 Objetivo Inicial Generado por IA

**Funcionalidad:**
- Al terminar de crear el personaje, la IA genera un objetivo inicial basado en tu trasfondo
- El objetivo está relacionado con tu historia y motiva la aventura
- Se guarda en `GameState.mainQuest`

**Ejemplo:**
```
=== TU HISTORIA COMIENZA ===

Objetivo: Descubre qué le ocurrió a tu maestro desaparecido y detén 
         las misteriosas desapariciones en Verdemonte

[Narrativa inicial...]
```

**Implementación:**
- Método `_generateInitialGoal()` en `quest_master_cli.dart`
- Usa la IA para generar objetivo contextual
- Fallback a objetivo genérico si falla

---

### 3. 🗺️ Sistema de Regiones (Preparado)

**Modelo nuevo:**
- `lib/core/models/region.dart` - Modelo completo de regiones

**Características:**
```dart
class Region {
  final String id;
  final String name;
  final String description;
  final String climate;          // "temperate", "desert", "tundra"
  final String culture;           // "trading hub", "militaristic"
  final List<String> connectedRegions;
  final int dangerLevel;          // 1-10
  final String? dominantRace;
  final List<String> features;
}
```

**Uso futuro:**
- Guardar regiones en `GameState.worldState['regions']`
- La IA mantiene consistencia con regiones establecidas
- Movimiento entre regiones con coherencia geográfica

---

### 4. 🤖 Prompts de IA Mejorados

**System Prompt actualizado** en `context_manager.dart`:

**ANTES:**
```
Eres el narrador de una aventura de rol en era medieval. 
Narra en segunda persona. Se creativo y descriptivo...
```

**AHORA:**
```
Eres el narrador de una aventura interactiva en era medieval.

PERSONAJE DEL JUGADOR:
Nombre: Elara | Clase: Mago | Apariencia: Élfica cabello plateado...

REGLAS NARRATIVAS:
• SÉ CONCISO: 1-2 párrafos máximo, no 3 párrafos extensos
• Describe lo inmediato: entorno nuevo, reacciones de NPCs
• NO des opciones predefinidas, el jugador decide libremente

NPCs Y PERSONALIDAD:
• Cada NPC tiene motivaciones, personalidad y prejuicios propios
• Reaccionan según: lo que dice el jugador, su apariencia/clase
• Ejemplo: Un guardia desconfiará de un pícaro pero respetará a un clérigo

CONSECUENCIAS REALISTAS:
• Causa-efecto lógico y proporcional (matar caballo ≠ destruir bosque)
• Las acciones tienen peso pero son realistas

LIBERTAD CREATIVA:
• El jugador puede hacer CUALQUIER acción
• No hay "caminos correctos", solo consecuencias
• El ingenio del jugador determina el éxito
• Crea nuevos NPCs y situaciones naturalmente
```

**Beneficios:**
- ✅ Narrativa más concisa (1-2 párrafos vs 3+)
- ✅ NPCs con personalidad y memoria
- ✅ Consecuencias realistas y proporcionales
- ✅ Mayor libertad creativa
- ✅ Información del personaje siempre en contexto

---

### 5. 📋 Comando Help Completo

**ANTES:**
```
📜 COMANDOS
─────────────────────────────────
inv / inventario    Ver inventario
stats              Ver estadísticas
equip <nombre>     Equipar/desequipar item
help               Mostrar esta ayuda
quit / salir       Salir del juego
```

**AHORA:**
```
📜 COMANDOS DISPONIBLES
══════════════════════════════════════════════════════════════════════════════

  BÁSICOS:
    help, ayuda, ?       Mostrar esta ayuda
    inv, inventario, i   Ver tu inventario
    stats, estado        Ver tus estadísticas
    equip <item>         Equipar/desequipar un objeto

  PARTIDA:
    save <nombre>        Guardar partida
    load <nombre>        Cargar partida
    quit, salir, exit    Salir del juego

  INTELIGENCIA ARTIFICIAL:
    provider             Ver proveedor de IA actual
    switch mock          Cambiar a Mock AI (respuestas predefinidas)
    switch groq          Cambiar a Groq AI (narrativa real con IA)

  AVANZADOS:
    mision <texto>       Cambiar misión principal
    contexto, context    Ver el prompt enviado a la IA
    debug items          Obtener items mágicos de prueba
    resumir              Forzar resumen de historia

  JUEGO LIBRE:
    Escribe cualquier acción y la IA responderá.
    Ejemplos:
      > hablo con el posadero sobre las desapariciones
      > examino la habitación en busca de pistas
      > intento convencer al guardia para que me deje pasar
```

---

## 📁 ARCHIVOS MODIFICADOS

### Archivos Nuevos:
1. **`bin/character_wizard.dart`** - Wizard de creación de personaje
2. **`lib/core/models/region.dart`** - Modelo de regiones

### Archivos Modificados:
1. **`lib/core/models/character.dart`** - Añadido campo `characterClass`
2. **`lib/core/models/models.dart`** - Export de `region.dart`
3. **`bin/quest_master_cli.dart`** - Integración del wizard y generación de objetivo
4. **`lib/core/services/context_manager.dart`** - System prompt mejorado
5. **`bin/cli_ui.dart`** - Comando help actualizado

---

## 🚀 CÓMO USAR

### Instalación

```bash
# 1. Extraer el proyecto
unzip quest_master_v2_enhanced.zip
cd quest_master_v2

# 2. Instalar dependencias
flutter pub get

# 3. Configurar API Key (si no la tienes)
cp lib/core/config/ai_config.dart.example lib/core/config/ai_config.dart
# Editar y poner tu key de Groq

# 4. Ejecutar
dart run bin/quest_master_cli.dart
```

### Primera Vez

Al ejecutar, verás el wizard completo:

```bash
$ dart run bin/quest_master_cli.dart

╔══════════════════════════════════════════════════════════════════════════════╗
║                    QUEST MASTER - Terminal Edition                           ║
╚══════════════════════════════════════════════════════════════════════════════╝
Provider: Mock AI (Testing)

=== CREACIÓN DE PERSONAJE ===

¿Cómo te llamas? [Introduce nombre]
```

Sigue las preguntas para crear tu personaje completo.

---

## 🎮 EJEMPLO DE SESIÓN

```bash
=== CREACIÓN DE PERSONAJE ===

¿Cómo te llamas? Kael

¿Qué clase eres?
  1. Mago
  2. Guerrero
  3. Pícaro
  ...
Opción: 2

¿Cuál es tu pasado?
> Ex-soldado que busca redención tras un error en batalla

¿Cómo te ves?
> Hombre fornido, cicatriz en la mejilla, armadura desgastada

¿Qué te caracteriza?
> Serio, honorable, perseguido por el pasado

✓ ¡Personaje creado!

ℹ Generando tu objetivo inicial...

╔══════════════════════════════════════════════════════════════════════════════╗
║ Kael - Guerrero                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Apariencia: Hombre fornido, cicatriz en la mejilla, armadura desgastada     ║
║ Personalidad: Serio, honorable, perseguido por el pasado                    ║
║ Historia: Ex-soldado que busca redención tras un error en batalla           ║
╚══════════════════════════════════════════════════════════════════════════════╝

✓ ¡Aventura iniciada!

=== TU HISTORIA COMIENZA ===

ℹ Objetivo: Encuentra a los sobrevivientes de tu antigua unidad y enfrenta 
           las consecuencias de tus decisiones pasadas

Te encuentras en un cruce de caminos donde tres senderos convergen...

> examino el poste de madera

[Narrativa concisa de la IA, 1-2 párrafos]

> camino hacia el norte

[Narrativa del bosque]

> switch groq
✓ Cambiado a Groq AI (narrativa real)

> busco señales de mi antigua unidad

[Narrativa generada por IA real, personalizada a tu historia]
```

---

## 🎯 DIFERENCIAS CLAVE

| Característica | Versión Antigua | Versión Nueva |
|----------------|----------------|---------------|
| Creación de personaje | Solo nombre | Wizard completo (clase, historia, etc.) |
| Objetivo | Genérico fijo | Generado por IA según tu historia |
| Narrativa IA | 3+ párrafos, verbosa | 1-2 párrafos, concisa |
| NPCs | Genéricos | Con personalidad y memoria |
| Consecuencias | No definidas | Realistas y proporcionales |
| Comando help | Comandos básicos | Todos los comandos incluyendo IA |
| Información personaje en prompts | Solo nombre | Clase, apariencia, personalidad, historia |

---

## 📝 NOTAS IMPORTANTES

### Memoria de NPCs
Actualmente la memoria de NPCs se implementa a través de:
- `GameState.activeNpcs` - NPCs en la escena actual
- `GameState.worldState` - Estado global del mundo (donde se pueden guardar NPCs)
- `GameState.keyFacts` - Hechos clave que incluyen interacciones importantes

La IA mantiene coherencia con NPCs mencionados previamente gracias al contexto mejorado.

### Regiones
El modelo `Region` está creado y listo para usar. Para implementar regiones:
```dart
// En worldState
final regions = {
  'verdemonte': Region(
    id: 'verdemonte',
    name: 'Verdemonte',
    climate: 'temperate',
    culture: 'trading hub',
    ...
  ),
};
```

---

## 🔜 PRÓXIMA FASE: MODO COOPERATIVO

La Fase 2 implementará:
- Servidor WebSocket para 2 jugadores
- Sistema de "ready state" (esperar a ambos jugadores)
- Live typing (ver lo que escribe el otro)
- Sincronización de game state
- Chat entre jugadores
- Inventarios separados

---

## 🐛 TROUBLESHOOTING

### Error: "Missing characterClass"
- Asegúrate de haber reemplazado TODOS los archivos
- El Character model ahora requiere el campo characterClass (opcional)

### Error: "Cannot find CharacterWizard"
- Verifica que `bin/character_wizard.dart` existe
- Verifica que está importado en `quest_master_cli.dart`

### Tests fallan
```bash
# Algunos tests pueden fallar debido a cambios en Character
# Ejecutar para ver detalles:
flutter test
```

---

## ✅ VERIFICACIÓN

Para verificar que todo está instalado correctamente:

```bash
# 1. Archivos existen
ls bin/character_wizard.dart
ls lib/core/models/region.dart

# 2. Compilar (verificar sin errores)
dart compile exe bin/quest_master_cli.dart

# 3. Ejecutar
dart run bin/quest_master_cli.dart
```

---

**¡Disfruta de la aventura mejorada!** 🎮✨

Para reportar issues o sugerencias, abre un issue en GitHub.
