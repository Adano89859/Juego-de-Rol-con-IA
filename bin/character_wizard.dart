import 'dart:io';
import 'package:quest_master/core/models/character.dart';
import 'package:quest_master/core/constants/game_constants.dart';
import 'package:uuid/uuid.dart';
import 'cli_ui.dart';

const _uuid = Uuid();

/// Character creation wizard for CLI
class CharacterWizard {
  
  /// Run the full character creation process
  static Future<Character> create() async {
    CliUI.printSeparator();
    print('${Ansi.brightCyan}${Ansi.bold}  CREACIÓN DE PERSONAJE${Ansi.reset}');
    CliUI.printSeparator();
    print('');
    
    // 1. Name
    stdout.write('${Ansi.brightYellow}¿Cómo te llamas?${Ansi.reset} ');
    final name = _readNonEmpty('Nombre');
    
    print('');
    
    // 2. Class
    CliUI.printInfo('¿Qué clase eres?');
    print('${Ansi.gray}  1.${Ansi.reset} Mago');
    print('${Ansi.gray}  2.${Ansi.reset} Guerrero');
    print('${Ansi.gray}  3.${Ansi.reset} Pícaro');
    print('${Ansi.gray}  4.${Ansi.reset} Clérigo');
    print('${Ansi.gray}  5.${Ansi.reset} Explorador');
    print('${Ansi.gray}  6.${Ansi.reset} Otra (describe)');
    stdout.write('${Ansi.brightYellow}Opción:${Ansi.reset} ');
    
    final classChoice = stdin.readLineSync()?.trim() ?? '1';
    String characterClass;
    
    switch (classChoice) {
      case '1':
        characterClass = 'Mago';
        break;
      case '2':
        characterClass = 'Guerrero';
        break;
      case '3':
        characterClass = 'Pícaro';
        break;
      case '4':
        characterClass = 'Clérigo';
        break;
      case '5':
        characterClass = 'Explorador';
        break;
      case '6':
        stdout.write('${Ansi.brightYellow}Escribe tu clase:${Ansi.reset} ');
        characterClass = _readNonEmpty('Clase');
        break;
      default:
        characterClass = 'Aventurero';
    }
    
    print('');
    
    // 3. Backstory
    CliUI.printInfo('¿Cuál es tu pasado? (2-3 líneas)');
    stdout.write('${Ansi.dim}Ejemplo: "Fui aprendiz de un mago que desapareció. Busco respuestas."${Ansi.reset}\n');
    stdout.write('${Ansi.brightYellow}Tu historia:${Ansi.reset}\n> ');
    final backstory = _readNonEmpty('Historia');
    
    print('');
    
    // 4. Appearance
    CliUI.printInfo('¿Cómo te ves? (apariencia física)');
    stdout.write('${Ansi.dim}Ejemplo: "Elfo de cabello plateado, ojos violetas, túnica azul"${Ansi.reset}\n');
    stdout.write('${Ansi.brightYellow}Tu apariencia:${Ansi.reset}\n> ');
    final appearance = _readNonEmpty('Apariencia');
    
    print('');
    
    // 5. Personality
    CliUI.printInfo('¿Qué te caracteriza? (personalidad/rasgos)');
    stdout.write('${Ansi.dim}Ejemplo: "Curioso, impulsivo, leal con los amigos"${Ansi.reset}\n');
    stdout.write('${Ansi.brightYellow}Tu personalidad:${Ansi.reset}\n> ');
    final personality = _readNonEmpty('Personalidad');
    
    print('');
    CliUI.printSuccess('¡Personaje creado!');
    print('');
    
    // Create Character object
    final now = DateTime.now();
    return Character(
      id: _uuid.v4(),
      name: name,
      characterClass: characterClass,
      backstory: backstory,
      appearance: appearance,
      personality: personality,
      description: '$name, un $characterClass',
      health: GameConstants.defaultHealth,
      maxHealth: GameConstants.defaultMaxHealth,
      attack: GameConstants.defaultAttack,
      defense: GameConstants.defaultDefense,
      speed: GameConstants.defaultSpeed,
      luck: GameConstants.defaultLuck,
      mana: GameConstants.defaultMana,
      maxMana: GameConstants.defaultMaxMana,
      createdAt: now,
    );
  }
  
  static String _readNonEmpty(String fieldName) {
    while (true) {
      final input = stdin.readLineSync()?.trim() ?? '';
      if (input.isNotEmpty) {
        return input;
      }
      stdout.write('${Ansi.red}$fieldName no puede estar vacío. Inténtalo de nuevo:${Ansi.reset} ');
    }
  }
}
