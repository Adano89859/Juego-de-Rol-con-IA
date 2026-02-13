/// Terminal UI helpers for Quest Master CLI.
///
/// Provides formatted output using ASCII box-drawing characters
/// and ANSI color codes for a pleasant terminal experience.
library;

import 'dart:io';

// ═══════════════════════════════════════════════════════════════════
// ANSI Color Codes
// ═══════════════════════════════════════════════════════════════════

class Ansi {
  Ansi._();

  static const reset = '\x1B[0m';
  static const bold = '\x1B[1m';
  static const dim = '\x1B[2m';
  static const italic = '\x1B[3m';
  static const underline = '\x1B[4m';

  // Foreground colors
  static const red = '\x1B[31m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const blue = '\x1B[34m';
  static const magenta = '\x1B[35m';
  static const cyan = '\x1B[36m';
  static const white = '\x1B[37m';
  static const gray = '\x1B[90m';

  // Bright foreground
  static const brightRed = '\x1B[91m';
  static const brightGreen = '\x1B[92m';
  static const brightYellow = '\x1B[93m';
  static const brightCyan = '\x1B[96m';
}

// ═══════════════════════════════════════════════════════════════════
// CLI UI Renderer
// ═══════════════════════════════════════════════════════════════════

class CliUI {
  static const _boxWidth = 56;

  /// Print the game banner on startup.
  static void printBanner() {
    print('');
    print('${Ansi.yellow}${Ansi.bold}'
        '╔${"═" * _boxWidth}╗${Ansi.reset}');
    _printBoxLine(
        '${Ansi.bold}QUEST MASTER - Terminal Edition${Ansi.reset}', center: true);
    _printBoxLine(
        '${Ansi.dim}Aventura narrativa con IA${Ansi.reset}', center: true);
    print('${Ansi.yellow}${Ansi.bold}'
        '╚${"═" * _boxWidth}╝${Ansi.reset}');
    print('');
  }

  /// Print a section separator.
  static void printSeparator() {
    print('${Ansi.gray}${"━" * (_boxWidth + 2)}${Ansi.reset}');
  }

  /// Print a thin separator.
  static void printThinSeparator() {
    print('${Ansi.gray}${"─" * (_boxWidth + 2)}${Ansi.reset}');
  }

  /// Print the player's current status bar.
  static void printStatusBar({
    required String location,
    required String healthNarrative,
    required String manaNarrative,
    required int turnCount,
    String? mainQuest,
    // Revealed stats (null if hidden)
    int? health,
    int? maxHealth,
    int? mana,
    int? maxMana,
    int? attack,
    int? defense,
    int? speed,
  }) {
    printSeparator();

    // Location
    print('${Ansi.cyan}  📍 $location${Ansi.reset}'
        '${Ansi.gray}  [Turno $turnCount]${Ansi.reset}');

    // Health
    if (health != null && maxHealth != null) {
      final bar = _makeBar(health, maxHealth, 20);
      final color = health / maxHealth > 0.5
          ? Ansi.green
          : health / maxHealth > 0.25
              ? Ansi.yellow
              : Ansi.red;
      print('  $color❤️  Salud: $health/$maxHealth $bar${Ansi.reset}');
    } else {
      print('  ${Ansi.green}❤️  $healthNarrative${Ansi.reset}');
    }

    // Mana
    if (mana != null && maxMana != null) {
      final bar = _makeBar(mana, maxMana, 20);
      print('  ${Ansi.blue}✨ Mana: $mana/$maxMana $bar${Ansi.reset}');
    } else {
      print('  ${Ansi.blue}✨ $manaNarrative${Ansi.reset}');
    }

    // Combat stats (if revealed)
    if (attack != null) {
      print('  ${Ansi.gray}⚔️  ATK:$attack  🛡 DEF:$defense  🏃 VEL:$speed${Ansi.reset}');
    }

    // Quest
    if (mainQuest != null) {
      print('  ${Ansi.yellow}⭐ Mision: $mainQuest${Ansi.reset}');
    }

    printSeparator();
  }

  /// Print AI narrative text with formatting.
  static void printNarrative(String text) {
    print('');
    // Word-wrap to fit terminal width
    final lines = _wordWrap(text, _boxWidth);
    for (final line in lines) {
      print('  ${Ansi.italic}${Ansi.white}$line${Ansi.reset}');
    }
    print('');
  }

  /// Print a player action echo.
  static void printPlayerAction(String action) {
    print('${Ansi.gray}  ▸ $action${Ansi.reset}');
  }

  /// Print the input prompt and return user input.
  static String prompt() {
    stdout.write(
        '${Ansi.brightYellow}¿Qué haces? > ${Ansi.reset}');
    final input = stdin.readLineSync() ?? '';
    return input.trim();
  }

  /// Print the inventory.
  static void printInventory(List<InventoryDisplayItem> items, {bool canSeeProperties = false}) {
    printSeparator();
    print('${Ansi.bold}  🎒 INVENTARIO${Ansi.reset}');
    printThinSeparator();

    if (items.isEmpty) {
      print('${Ansi.gray}  (Vacío)${Ansi.reset}');
    } else {
      for (final item in items) {
        final equipped = item.isEquipped ? ' ${Ansi.green}[E]${Ansi.reset}' : '';
        final typeTag = '${Ansi.gray}[${item.type}]${Ansi.reset}';
        print('  $typeTag ${Ansi.white}${item.name}$equipped${Ansi.reset}');

        if (canSeeProperties) {
          final bonuses = <String>[];
          if (item.attackBonus != null && item.attackBonus! > 0) {
            bonuses.add('+${item.attackBonus} ATK');
          }
          if (item.defenseBonus != null && item.defenseBonus! > 0) {
            bonuses.add('+${item.defenseBonus} DEF');
          }
          if (bonuses.isNotEmpty) {
            print('${Ansi.gray}        ${bonuses.join("  ")}${Ansi.reset}');
          }
        }

        if (item.description != null) {
          print('${Ansi.dim}        ${item.description}${Ansi.reset}');
        }
      }
    }

    printSeparator();
  }

  /// Print stats panel (for the 'stats' command).
  static void printStats({
    required String name,
    String? title,
    required bool canSeeStats,
    required String healthNarrative,
    required String manaNarrative,
    required int health,
    required int maxHealth,
    required int attack,
    required int defense,
    required int speed,
    required int luck,
    required int mana,
    required int maxMana,
    required List<String> abilities,
  }) {
    printSeparator();
    final displayName = title != null ? '$name ($title)' : name;
    print('${Ansi.bold}  👤 $displayName${Ansi.reset}');
    printThinSeparator();

    if (canSeeStats) {
      final hpBar = _makeBar(health, maxHealth, 20);
      final mpBar = _makeBar(mana, maxMana, 20);
      final hpColor = health / maxHealth > 0.5
          ? Ansi.green
          : health / maxHealth > 0.25
              ? Ansi.yellow
              : Ansi.red;

      print('  ${hpColor}❤️  Salud: $health/$maxHealth $hpBar${Ansi.reset}');
      print('  ${Ansi.blue}✨ Mana:  $mana/$maxMana $mpBar${Ansi.reset}');
      print('');
      print('  ${Ansi.white}⚔️  Ataque:   $attack${Ansi.reset}');
      print('  ${Ansi.white}🛡  Defensa:  $defense${Ansi.reset}');
      print('  ${Ansi.white}🏃 Velocidad: $speed${Ansi.reset}');
      print('  ${Ansi.white}🍀 Suerte:    $luck${Ansi.reset}');
    } else {
      print('  ${Ansi.green}❤️  $healthNarrative${Ansi.reset}');
      print('  ${Ansi.blue}✨ $manaNarrative${Ansi.reset}');
      print('');
      print('${Ansi.dim}  (Necesitas "Ojo de Verdad" para ver tus stats)${Ansi.reset}');
    }

    if (abilities.isNotEmpty) {
      print('');
      print('  ${Ansi.magenta}Habilidades: ${abilities.join(", ")}${Ansi.reset}');
    }

    printSeparator();
  }

  /// Print a help screen with all commands.
  static void printHelp() {
    printSeparator();
    print('${Ansi.bold}  📜 COMANDOS DISPONIBLES${Ansi.reset}');
    printSeparator();
    
    print('${Ansi.bold}  BÁSICOS:${Ansi.reset}');
    print('    ${Ansi.brightCyan}help, ayuda, ?${Ansi.reset}       Mostrar esta ayuda');
    print('    ${Ansi.brightCyan}inv, inventario, i${Ansi.reset}   Ver tu inventario');
    print('    ${Ansi.brightCyan}stats, estado${Ansi.reset}        Ver tus estadísticas');
    print('    ${Ansi.brightCyan}equip <item>${Ansi.reset}         Equipar/desequipar un objeto');
    print('');
    
    print('${Ansi.bold}  PARTIDA:${Ansi.reset}');
    print('    ${Ansi.brightCyan}save <nombre>${Ansi.reset}        Guardar partida');
    print('    ${Ansi.brightCyan}load <nombre>${Ansi.reset}        Cargar partida');
    print('    ${Ansi.brightCyan}quit, salir, exit${Ansi.reset}    Salir del juego');
    print('');
    
    print('${Ansi.bold}  INTELIGENCIA ARTIFICIAL:${Ansi.reset}');
    print('    ${Ansi.brightCyan}provider${Ansi.reset}             Ver proveedor de IA actual');
    print('    ${Ansi.brightCyan}switch mock${Ansi.reset}          Cambiar a Mock AI (respuestas predefinidas)');
    print('    ${Ansi.brightCyan}switch groq${Ansi.reset}          Cambiar a Groq AI (narrativa real con IA)');
    print('');
    
    print('${Ansi.bold}  AVANZADOS:${Ansi.reset}');
    print('    ${Ansi.brightCyan}mision <texto>${Ansi.reset}       Cambiar misión principal');
    print('    ${Ansi.brightCyan}contexto, context${Ansi.reset}    Ver el prompt enviado a la IA');
    print('    ${Ansi.brightCyan}debug items${Ansi.reset}          Obtener items mágicos de prueba');
    print('    ${Ansi.brightCyan}resumir${Ansi.reset}              Forzar resumen de historia');
    print('');
    
    printThinSeparator();
    print('${Ansi.bold}  JUEGO LIBRE:${Ansi.reset}');
    print('${Ansi.dim}    Escribe cualquier acción y la IA responderá.${Ansi.reset}');
    print('${Ansi.dim}    Ejemplos:${Ansi.reset}');
    print('${Ansi.dim}      > hablo con el posadero sobre las desapariciones${Ansi.reset}');
    print('${Ansi.dim}      > examino la habitación en busca de pistas${Ansi.reset}');
    print('${Ansi.dim}      > intento convencer al guardia para que me deje pasar${Ansi.reset}');
    printSeparator();
  }

  /// Print an error message.
  static void printError(String message) {
    print('${Ansi.red}  ⚠ Error: $message${Ansi.reset}');
  }

  /// Print an info message.
  static void printInfo(String message) {
    print('${Ansi.cyan}  ℹ $message${Ansi.reset}');
  }

  /// Print a success message.
  static void printSuccess(String message) {
    print('${Ansi.green}  ✓ $message${Ansi.reset}');
  }

  /// Print a "thinking" indicator.
  static void printThinking() {
    stdout.write('${Ansi.dim}  ⏳ La historia se escribe...${Ansi.reset}');
  }

  /// Clear the thinking indicator.
  static void clearThinking() {
    stdout.write('\r${" " * 50}\r');
  }

  /// Print the context debug view.
  static void printContextDebug(String prompt, int estimatedTokens) {
    printSeparator();
    print('${Ansi.bold}  🔍 DEBUG: Prompt enviado a la IA${Ansi.reset}');
    print('${Ansi.gray}  Tokens estimados: $estimatedTokens${Ansi.reset}');
    printThinSeparator();
    // Show the prompt with dim formatting
    final lines = prompt.split('\n');
    for (final line in lines) {
      print('${Ansi.dim}  $line${Ansi.reset}');
    }
    printSeparator();
  }

  // ── Private Helpers ──

  static void _printBoxLine(String text, {bool center = false}) {
    // Strip ANSI codes for length calculation
    final plainText = text.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
    final padding = _boxWidth - plainText.length;
    final left = center ? padding ~/ 2 : 1;
    final right = center ? padding - left : padding - 1;

    print('${Ansi.yellow}${Ansi.bold}║${Ansi.reset}'
        '${" " * left}$text${" " * right}'
        '${Ansi.yellow}${Ansi.bold}║${Ansi.reset}');
  }

  static String _makeBar(int current, int max, int width) {
    if (max <= 0) return '[${"░" * width}]';
    final filled = ((current / max) * width).round().clamp(0, width);
    final empty = width - filled;
    return '[${Ansi.bold}${"█" * filled}${Ansi.reset}${"░" * empty}]';
  }

  static List<String> _wordWrap(String text, int maxWidth) {
    final lines = <String>[];
    // Split by existing newlines first
    for (final paragraph in text.split('\n')) {
      if (paragraph.isEmpty) {
        lines.add('');
        continue;
      }
      final words = paragraph.split(' ');
      var currentLine = StringBuffer();
      for (final word in words) {
        if (currentLine.length + word.length + 1 > maxWidth) {
          lines.add(currentLine.toString());
          currentLine = StringBuffer(word);
        } else {
          if (currentLine.isNotEmpty) currentLine.write(' ');
          currentLine.write(word);
        }
      }
      if (currentLine.isNotEmpty) {
        lines.add(currentLine.toString());
      }
    }
    return lines;
  }
}

/// Simple data class for inventory display (avoids importing Flutter-dependent code).
class InventoryDisplayItem {
  final String name;
  final String type;
  final bool isEquipped;
  final String? description;
  final int? attackBonus;
  final int? defenseBonus;

  const InventoryDisplayItem({
    required this.name,
    required this.type,
    this.isEquipped = false,
    this.description,
    this.attackBonus,
    this.defenseBonus,
  });
}
