# 🎮 Quest Master - Con Groq AI Integrado

## ⚡ QUICK START (5 minutos)

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Configurar API Key
Edita `lib/core/config/ai_config.dart`:
```dart
static const groqApiKey = 'TU_KEY_AQUI'; // ← Cambia esto
```

### 3. Ejecutar
```bash
dart run bin/quest_master_cli.dart
```

### 4. Cambiar a Groq
```
> switch groq
> explora el bosque
```

---

## 📖 Documentación Completa
Ver **`INSTRUCCIONES_INSTALACION.md`** para guía paso a paso completa.

---

## 🆕 Archivos Agregados
- `lib/core/config/ai_config.dart` - Configuración de IA
- `lib/core/services/ai_service_factory.dart` - Factory de servicios
- `lib/services/groq_ai_service.dart` - Servicio de Groq
- `bin/quest_master_cli.dart` - CLI actualizado

---

## 🎯 Comandos Clave
- `provider` - Ver IA actual
- `switch groq` - Usar IA real
- `switch mock` - Volver a testing
- `debug items` - Obtener items mágicos
- `help` - Ver todos los comandos

---

**⚠️ IMPORTANTE:** Obtén tu API key en https://console.groq.com/keys (gratis)
