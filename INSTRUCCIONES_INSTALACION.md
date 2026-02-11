# 🎮 QUEST MASTER - Guía de Instalación y Ejecución

## 📋 Archivos Nuevos Agregados

✅ **lib/core/config/ai_config.dart** - Configuración de proveedores de IA
✅ **lib/core/services/ai_service_factory.dart** - Factory para crear servicios
✅ **lib/services/groq_ai_service.dart** - Servicio de Groq AI (LLaMA 3.3)
✅ **bin/quest_master_cli.dart** - CLI actualizado con soporte para Groq

---

## 🚀 INSTALACIÓN PASO A PASO

### Paso 1: Extraer el Proyecto

Extrae el archivo ZIP del proyecto en tu carpeta de trabajo.

```bash
unzip Juego-de-Rol-con-IA-claude-quest-master-game-design-kHbqC.zip
cd Juego-de-Rol-con-IA-claude-quest-master-game-design-kHbqC
```

---

### Paso 2: Instalar Dependencias

```bash
flutter pub get
```

**Nota:** Si no tienes Flutter instalado, el proyecto también funciona solo con Dart:
```bash
dart pub get
```

---

### Paso 3: ⚠️ CONFIGURAR TU API KEY DE GROQ

**IMPORTANTE:** Antes de ejecutar, debes configurar tu API key.

#### 3.1. Regenera tu API Key (IMPORTANTE - tu key anterior fue expuesta)

1. Ve a: https://console.groq.com/keys
2. Borra cualquier key existente
3. Crea una nueva API key
4. Copia la key (comienza con `gsk_...`)

#### 3.2. Configura la Key en el Proyecto

Abre el archivo: **`lib/core/config/ai_config.dart`**

Busca esta línea:
```dart
static const groqApiKey = 'PONER_TU_KEY_AQUI';
```

Reemplázala con:
```dart
static const groqApiKey = 'gsk_TU_KEY_AQUI'; // ← Pega tu key real aquí
```

**⚠️ NUNCA SUBAS ESTE ARCHIVO A GIT CON TU KEY REAL**

---

### Paso 4: Ejecutar el Juego

```bash
dart run bin/quest_master_cli.dart
```

Deberías ver:

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    QUEST MASTER - Terminal Edition                           ║
║                    Provider: Mock AI (Testing)                               ║
╚══════════════════════════════════════════════════════════════════════════════╝

  Nombre de tu personaje [Aventurero]: _
```

---

## 🎮 COMANDOS DEL JUEGO

### Comandos Básicos:
- `help` / `ayuda` - Mostrar todos los comandos
- `inv` / `inventario` - Ver tu inventario
- `stats` / `estado` - Ver tus estadísticas
- `save <nombre>` - Guardar partida
- `load <nombre>` - Cargar partida
- `quit` / `salir` - Salir del juego

### Comandos de IA:
- `provider` - Ver proveedor actual (Mock o Groq)
- `switch mock` - Cambiar a Mock AI (respuestas predefinidas)
- `switch groq` - Cambiar a Groq AI (narrativa real con IA)

### Comandos de Debug:
- `debug items` - Obtener items de visión para ver stats
- `contexto` - Ver el prompt que se envía a la IA

### Equipar Items:
- `equip <nombre>` - Equipar/desequipar un item
- Ejemplo: `equip ojo de verdad` - Te permite ver tus stats reales

---

## 🔄 PROBAR GROQ AI

### Paso 1: Iniciar con Mock
```
> provider
Proveedor actual: Mock AI (Testing)
```

### Paso 2: Cambiar a Groq
```
> switch groq
✓ Cambiado a Groq AI (llama-3.3-70b-versatile)
Conectando con Groq... primera respuesta puede tardar un poco.
```

### Paso 3: Jugar con IA Real
```
> exploro el bosque oscuro
[Aquí verás narrativa REAL generada por la IA de Groq]
```

### Paso 4: Volver a Mock (si quieres)
```
> switch mock
✓ Cambiado a Mock AI (respuestas predefinidas)
```

---

## 🎯 EJEMPLO DE SESIÓN COMPLETA

```bash
$ dart run bin/quest_master_cli.dart

╔══════════════════════════════════════════════════════════════════════════════╗
║                    QUEST MASTER - Terminal Edition                           ║
║                    Provider: Mock AI (Testing)                               ║
╚══════════════════════════════════════════════════════════════════════════════╝

  Nombre de tu personaje [Aventurero]: Aragorn

Iniciando aventura como Aragorn...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Ubicación: Encrucijada del Destino
❤️  Estado: Te sientes en perfecto estado
✨ Maná: Estás lleno de energía
[Turno 0]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Te encuentras en un cruce de caminos donde tres senderos convergen...

> switch groq
✓ Cambiado a Groq AI (llama-3.3-70b-versatile)

> camino hacia el norte

💭 Aragorn dice: "camino hacia el norte"

⏳ Pensando...

Te adentras en el bosque denso. La luz del día apenas penetra entre las 
copas de los árboles. Escuchas el crujir de ramas bajo tus pies y el 
canto lejano de pájaros desconocidos. De repente, notas un sendero 
apenas visible que se desvía hacia tu izquierda...

  📍 Encrucijada del Destino  [T1]

> debug items
Items de debug añadidos al inventario:
  - Ojo de Verdad (equip para ver tus stats)
  - Visión Mística (equip para ver stats de enemigos)
  - Gafas de Análisis (equip para ver propiedades de items)
  - Espada de Acero (+8 ATK, +2 DEF)

> equip ojo
Equipaste: Ojo de Verdad
Sientes un poder nuevo fluir... tu percepción se expande.

> stats

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 ESTADÍSTICAS - Aragorn
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❤️  Salud: 92/100 [██████████████████░░]
✨ Maná: 50/50 [████████████████████]

⚔️  Ataque: 10
🛡️  Defensa: 8
💨 Velocidad: 12
🍀 Suerte: 15
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

> save mi_partida
Partida guardada en: mi_partida

> quit
Gracias por jugar Quest Master!
```

---

## 🔧 TROUBLESHOOTING

### Error: "API Key de Groq no configurada"
**Solución:** Edita `lib/core/config/ai_config.dart` y coloca tu key real

### Error: "Error al conectar con Groq"
**Soluciones:**
1. Verifica que tu API key sea correcta
2. Verifica tu conexión a internet
3. Usa `switch mock` para volver a respuestas predefinidas

### Error: "Package not found"
**Solución:** Ejecuta `flutter pub get` o `dart pub get`

### La narrativa de Groq es muy lenta
**Esto es normal en la primera request.** Las siguientes serán más rápidas.

---

## 📊 LÍMITES DE GROQ (Tier Gratuito)

- ✅ 14,400 requests por día
- ✅ 30 requests por minuto
- ✅ Suficiente para ~500-1000 turnos de juego por día

---

## 🎮 PRÓXIMOS PASOS

1. ✅ **Juega con Mock primero** para aprender los comandos
2. ✅ **Obtén items de debug** con `debug items`
3. ✅ **Equipa "Ojo de Verdad"** para ver tus stats
4. ✅ **Cambia a Groq** con `switch groq`
5. ✅ **Experimenta con acciones libres** - ¡la IA es creativa!
6. ✅ **Guarda tu progreso** con `save nombre_partida`

---

## 🐛 REPORTAR PROBLEMAS

Si encuentras errores:
1. Verifica que seguiste todos los pasos
2. Asegúrate de tener Flutter/Dart instalado
3. Verifica que tu API key esté configurada correctamente

---

## 🌟 CARACTERÍSTICAS

✨ Input libre - Escribe lo que quieras hacer
✨ IA real con Groq - Narrativa única en cada partida
✨ Sistema de visión progresiva - Descubre stats poco a poco
✨ Guardado/cargado de partidas
✨ Stats ocultos que se revelan con items especiales
✨ Cambio fácil entre Mock y Groq
✨ Optimizado para modelos de IA locales (Ollama)

---

**¡Disfruta tu aventura en Quest Master!** 🎮✨
