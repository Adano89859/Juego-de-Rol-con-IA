/// Quest Master CLI - Terminal Edition
///
/// A playable CLI version that reuses ALL core logic from the Flutter app.
/// Run with: dart run bin/quest_master_cli.dart
library;

import 'dart:io';
import 'dart:convert';

import 'package:quest_master/core/constants/game_constants.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/core/services/context_manager.dart';
import 'package:quest_master/core/services/ai_service.dart';
import 'package:quest_master/core/config/ai_config.dart';
import 'package:quest_master/core/services/ai_service_factory.dart';
import 'package:quest_master/core/utils/vision_system.dart';
import 'package:uuid/uuid.dart';

import 'cli_ui.dart';
import 'character_wizard.dart';

const _uuid = Uuid();

// ═══════════════════════════════════════════════════════════════════
// Main Entry Point
// ═══════════════════════════════════════════════════════════════════

Future<void> main(List<String> args) async {
  final game = QuestMasterCLI();

  // Handle Ctrl+C gracefully
  ProcessSignal.sigint.watch().listen((_) {
    print('');
    CliUI.printInfo('Saliendo de Quest Master...');
    exit(0);
  });

  await game.run();
}

// ═══════════════════════════════════════════════════════════════════
// CLI Game Controller
// ═══════════════════════════════════════════════════════════════════

class QuestMasterCLI {
  AIProvider _currentProvider = AIConfig.provider;
  late AIService _aiService;
  final ContextManager _contextManager = ContextManager();
  late GameState _state;

  static const _saveDir = 'cli_saves';

  /// Select AI provider at startup
  Future<AIProvider> _selectProvider() async {
    print('');
    CliUI.printInfo('¿Qué proveedor de IA deseas usar?');
    print('${Ansi.cyan}  1.${Ansi.reset} Mock AI ${Ansi.gray}(respuestas predefinidas, rápido)${Ansi.reset}');
    print('${Ansi.cyan}  2.${Ansi.reset} Groq AI ${Ansi.gray}(narrativa real con IA, requiere conexión)${Ansi.reset}');
    stdout.write('${Ansi.brightYellow}Opción (1-2):${Ansi.reset} ');
    
    final choice = stdin.readLineSync()?.trim() ?? '1';
    
    if (choice == '2') {
      try {
        // Test Groq connection
        final testService = createAIService(provider: AIProvider.groq);
        CliUI.printInfo('Probando conexión con Groq...');
        final available = await testService.isAvailable();
        if (available) {
          CliUI.printSuccess('✓ Conectado a Groq AI');
          return AIProvider.groq;
        } else {
          CliUI.printError('No se pudo conectar a Groq. Usando Mock AI.');
          return AIProvider.mock;
        }
      } catch (e) {
        CliUI.printError('Error: $e');
        CliUI.printInfo('Usando Mock AI por defecto.');
        return AIProvider.mock;
      }
    }
    
    return AIProvider.mock;
  }

  Future<void> run() async {
    _showHeader();
    
    // Select AI provider first
    _currentProvider = await _selectProvider();
    
    try {
      _aiService = createAIService(provider: _currentProvider);
    } catch (e) {
      CliUI.printError('Error al inicializar IA: $e');
      CliUI.printInfo('Usando Mock AI por defecto...');
      _currentProvider = AIProvider.mock;
      _aiService = createAIService(provider: _currentProvider);
    }

    print('');
    print('${Ansi.cyan}Provider: ${getProviderName(_currentProvider)}${Ansi.reset}\n');

    // Run character creation wizard
    final player = await CharacterWizard.create();
    
    // Generate initial objective based on character
    CliUI.printInfo('Generando tu objetivo inicial...');
    final goal = await _generateInitialGoal(player);

    // Initialize game state with created character
    _state = _createInitialState(player, goal);

    CliUI.printSuccess('¡Aventura iniciada!');
    print('');

    // Show character summary
    _printCharacterSummary();
    print('');

    // Show initial status
    _printStatus();

    // Show the opening narrative with objective
    CliUI.printSeparator();
    print('${Ansi.brightCyan}${Ansi.bold}  TU HISTORIA COMIENZA${Ansi.reset}');
    CliUI.printSeparator();
    print('');
    CliUI.printInfo('Objetivo: $goal');
    print('');
    
    // Generate creative opening scene
    if (_currentProvider == AIProvider.groq) {
      CliUI.printInfo('La IA está creando tu historia inicial...');
      final openingScene = await _generateCreativeOpening(player);
      print('');
      CliUI.printNarrative(openingScene);
    } else {
      // Mock fallback
      CliUI.printNarrative(
        'Tu aventura comienza. El objetivo es claro: $goal',
      );
    }

    // Main game loop
    await _gameLoop();
  }

  void _showHeader() {
    print('\n' * 2);
    CliUI.printBanner();
  }

  Future<void> _gameLoop() async {
    while (true) {
      final input = CliUI.prompt();

      if (input.isEmpty) continue;

      // Check for special commands first
      if (await _handleCommand(input)) continue;

      // Process as game action
      await _processAction(input);
    }
  }

  Future<bool> _handleCommand(String input) async {
    final lower = input.toLowerCase();
    final parts = lower.split(' ');
    final cmd = parts.first;

    switch (cmd) {
      case 'quit':
      case 'salir':
      case 'exit':
        CliUI.printInfo('Gracias por jugar Quest Master!');
        exit(0);

      case 'help':
      case 'ayuda':
      case '?':
        CliUI.printHelp();
        return true;

      case 'inv':
      case 'inventario':
      case 'i':
        _showInventory();
        return true;

      case 'stats':
      case 'estado':
        _showStats();
        return true;

      case 'equip':
      case 'equipar':
        _handleEquip(input.substring(cmd.length).trim());
        return true;

      case 'mision':
      case 'quest':
        final quest = input.substring(cmd.length).trim();
        if (quest.isNotEmpty) {
          _state = _state.copyWith(mainQuest: quest);
          CliUI.printSuccess('Misión actualizada: $quest');
        } else {
          if (_state.mainQuest != null) {
            CliUI.printInfo('Misión actual: ${_state.mainQuest}');
          } else {
            CliUI.printInfo('No tienes una misión activa.');
          }
        }
        return true;

      case 'resumir':
        await _performSummarization();
        return true;

      case 'contexto':
      case 'context':
        _showContext();
        return true;

      case 'save':
      case 'guardar':
        final slot = parts.length > 1 ? parts.sublist(1).join('_') : 'autosave';
        await _saveGame(slot);
        return true;

      case 'load':
      case 'cargar':
        final slot = parts.length > 1 ? parts.sublist(1).join('_') : 'autosave';
        await _loadGame(slot);
        return true;

      case 'provider':
        print('');
        CliUI.printInfo('Proveedor actual: ${getProviderName(_currentProvider)}');
        CliUI.printInfo('Usa "switch mock" o "switch groq" para cambiar');
        print('');
        return true;

      case 'switch':
        if (parts.length < 2) {
          CliUI.printError('Uso: switch <mock|groq>');
          return true;
        }
        final newProvider = parts[1].toLowerCase();
        if (newProvider == 'mock') {
          _currentProvider = AIProvider.mock;
          try {
            _aiService = createAIService(provider: _currentProvider);
            CliUI.printSuccess('✓ Cambiado a Mock AI (respuestas predefinidas)');
            print('');
            print('${Ansi.cyan}Provider: ${getProviderName(_currentProvider)}${Ansi.reset}\n');
          } catch (e) {
            CliUI.printError('Error al cambiar: $e');
          }
        } else if (newProvider == 'groq') {
          try {
            _currentProvider = AIProvider.groq;
            _aiService = createAIService(provider: _currentProvider);
            CliUI.printSuccess('✓ Cambiado a Groq AI (narrativa real)');
            CliUI.printInfo('Conectando con Groq... primera respuesta puede tardar un poco.');
            print('');
            print('${Ansi.cyan}Provider: ${getProviderName(_currentProvider)}${Ansi.reset}\n');
          } catch (e) {
            CliUI.printError('Error: $e');
            CliUI.printError('Volviendo a Mock AI...');
            _currentProvider = AIProvider.mock;
            _aiService = createAIService(provider: _currentProvider);
            print('');
            print('${Ansi.cyan}Provider: ${getProviderName(_currentProvider)}${Ansi.reset}\n');
          }
        } else {
          CliUI.printError('Proveedor desconocido. Usa: mock o groq');
        }
        return true;

      case 'debug':
        if (parts.length > 1 && parts[1] == 'items') {
          _debugGiveVisionItems();
          return true;
        }
        return false;

      default:
        return false;
    }
  }

  Future<void> _processAction(String playerInput) async {
    CliUI.printPlayerAction(playerInput);

    // Check if summarization is needed
    if (_contextManager.needsSummarization(_state)) {
      CliUI.printInfo('Resumiendo historia antigua...');
      await _performSummarization();
    }

    // Build optimized prompt (reusing ContextManager)
    final prompt = _contextManager.buildPrompt(
      state: _state,
      playerInput: playerInput,
    );

    // Show thinking indicator
    CliUI.printThinking();

    try {
      // Get AI response
      final response = await _aiService.narrate(
        prompt: prompt,
        maxTokens: 1000,
      );

      CliUI.clearThinking();

      // Create event
      final event = GameEvent(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        playerAction: playerInput,
        narrative: response.narrative,
        stateChanges: response.stateChanges,
        tags: _inferTags(playerInput),
      );

      // Update state
      _state = _state.copyWith(
        events: [..._state.events, event],
        turnCount: _state.turnCount + 1,
      );

      // Apply state changes
      _applyStateChanges(response.stateChanges);

      // Print narrative
      CliUI.printNarrative(response.narrative);

      // Show mini status
      _printMiniStatus();
    } catch (e) {
      CliUI.clearThinking();
      CliUI.printError('Error al procesar acción: $e');
      if (_currentProvider == AIProvider.groq) {
        CliUI.printInfo('Tip: Usa "switch mock" para volver a respuestas predefinidas');
      }
    }
  }

  void _showInventory() {
    final items = _state.inventory.values.map((item) {
      return InventoryDisplayItem(
        name: item.name,
        type: item.type.name,
        isEquipped: item.isEquipped,
        description: item.description,
        attackBonus: item.attackBonus,
        defenseBonus: item.defenseBonus,
      );
    }).toList();

    CliUI.printInventory(
      items,
      canSeeProperties: _state.playerHasItemVision,
    );
  }

  void _showStats() {
    final vision = VisionSystem.getPlayerVision(_state);

    CliUI.printStats(
      name: _state.player.name,
      title: _state.player.title,
      canSeeStats: vision.canSeeHealth,
      healthNarrative: vision.healthNarrative,
      manaNarrative: vision.manaNarrative,
      health: vision.health,
      maxHealth: vision.maxHealth,
      attack: vision.attack,
      defense: vision.defense,
      speed: vision.speed,
      luck: vision.luck,
      mana: vision.mana,
      maxMana: vision.maxMana,
      abilities: _state.player.abilities,
    );
  }

  void _handleEquip(String itemName) {
    if (itemName.isEmpty) {
      CliUI.printError('Uso: equip <nombre del item>');
      return;
    }

    final lower = itemName.toLowerCase();
    final entry = _state.inventory.entries.where(
      (e) => e.value.name.toLowerCase().contains(lower),
    );

    if (entry.isEmpty) {
      CliUI.printError('No tienes "$itemName" en tu inventario.');
      return;
    }

    final item = entry.first.value;
    final newItem = item.copyWith(isEquipped: !item.isEquipped);
    final inventory = Map<String, GameItem>.from(_state.inventory);
    inventory[item.id] = newItem;

    var player = _state.player;
    if (newItem.isEquipped) {
      if (newItem.grantsSelfVision) {
        player = player.copyWith(hasSelfVision: true);
      }
      if (newItem.grantsEnemyVision) {
        player = player.copyWith(hasEnemyVision: true);
      }
      if (newItem.grantsItemVision) {
        player = player.copyWith(hasItemVision: true);
      }
    }

    _state = _state.copyWith(inventory: inventory, player: player);

    if (newItem.isEquipped) {
      CliUI.printSuccess('Equipaste: ${item.name}');
      if (newItem.isVisionItem) {
        CliUI.printSuccess('Sientes un poder nuevo fluir... tu percepción se expande.');
      }
    } else {
      CliUI.printInfo('Desequipaste: ${item.name}');
    }
  }

  void _showContext() {
    final prompt = _contextManager.buildPrompt(
      state: _state,
      playerInput: '<acción del jugador aquí>',
    );
    final tokens = GameConstants.estimateTokens(prompt);
    CliUI.printContextDebug(prompt, tokens);
  }

  void _debugGiveVisionItems() {
    final now = DateTime.now();

    final trueEye = GameItem(
      id: _uuid.v4(),
      name: 'Ojo de Verdad',
      type: ItemType.vision,
      grantsSelfVision: true,
      description: 'Te permite ver tus propias estadísticas',
      rarity: 'rare',
      createdAt: now,
    );

    final mysticVision = GameItem(
      id: _uuid.v4(),
      name: 'Visión Mística',
      type: ItemType.vision,
      grantsEnemyVision: true,
      description: 'Revela las estadísticas de enemigos',
      rarity: 'rare',
      createdAt: now,
    );

    final analysisGlasses = GameItem(
      id: _uuid.v4(),
      name: 'Gafas de Análisis',
      type: ItemType.vision,
      grantsItemVision: true,
      description: 'Muestra las propiedades ocultas de los objetos',
      rarity: 'rare',
      createdAt: now,
    );

    final sword = GameItem(
      id: _uuid.v4(),
      name: 'Espada de Acero',
      type: ItemType.weapon,
      attackBonus: 8,
      defenseBonus: 2,
      description: 'Una espada bien forjada',
      rarity: 'common',
      createdAt: now,
    );

    final inventory = Map<String, GameItem>.from(_state.inventory);
    inventory[trueEye.id] = trueEye;
    inventory[mysticVision.id] = mysticVision;
    inventory[analysisGlasses.id] = analysisGlasses;
    inventory[sword.id] = sword;

    _state = _state.copyWith(inventory: inventory);

    CliUI.printSuccess('Items de debug añadidos al inventario:');
    CliUI.printInfo('  - Ojo de Verdad (equip para ver tus stats)');
    CliUI.printInfo('  - Visión Mística (equip para ver stats de enemigos)');
    CliUI.printInfo('  - Gafas de Análisis (equip para ver propiedades de items)');
    CliUI.printInfo('  - Espada de Acero (+8 ATK, +2 DEF)');
    CliUI.printInfo('Usa "equip <nombre>" para equipar.');
  }

  Future<void> _performSummarization() async {
    final eventsToSummarize = _state.events
        .take(_state.events.length - GameConstants.recentEventsCount)
        .toList();

    if (eventsToSummarize.isEmpty) {
      CliUI.printInfo('No hay suficientes eventos para resumir.');
      return;
    }

    final summaryPrompt =
        _contextManager.buildSummarizationPrompt(eventsToSummarize);
    
    try {
      final summary = await _aiService.summarize(prompt: summaryPrompt);

      final newFacts = _contextManager.extractKeyFacts(
        _state.keyFacts,
        eventsToSummarize,
      );

      final recentEvents = _state.events.length > GameConstants.recentEventsCount
          ? _state.events.sublist(
              _state.events.length - GameConstants.recentEventsCount)
          : _state.events;

      final combinedSummary = _state.storySummary.isEmpty
          ? summary
          : '${_state.storySummary} $summary';

      _state = _state.copyWith(
        storySummary: combinedSummary,
        keyFacts: newFacts,
        events: recentEvents,
      );

      CliUI.printSuccess(
          'Historia resumida. ${eventsToSummarize.length} eventos comprimidos.');
      CliUI.printInfo('Resumen: $summary');
    } catch (e) {
      CliUI.printError('Error al resumir: $e');
    }
  }

  Future<void> _saveGame(String slot) async {
    try {
      final dir = Directory(_saveDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final file = File('$_saveDir/$slot.json');
      final json = const JsonEncoder.withIndent('  ').convert(_state.toJson());
      file.writeAsStringSync(json);

      CliUI.printSuccess('Partida guardada en: $slot');
    } catch (e) {
      CliUI.printError('No se pudo guardar: $e');
    }
  }

  Future<void> _loadGame(String slot) async {
    try {
      final file = File('$_saveDir/$slot.json');
      if (!file.existsSync()) {
        CliUI.printError('No existe la partida: $slot');

        final dir = Directory(_saveDir);
        if (dir.existsSync()) {
          final saves = dir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.json'))
              .map((f) => f.path.split('/').last.replaceAll('.json', ''))
              .toList();
          if (saves.isNotEmpty) {
            CliUI.printInfo('Partidas disponibles: ${saves.join(", ")}');
          }
        }
        return;
      }

      final content = file.readAsStringSync();
      _state = GameState.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      );

      CliUI.printSuccess('Partida cargada: $slot');
      _printStatus();
      CliUI.printNarrative(
        _state.currentLocation.description ??
            'Continúas tu aventura...',
      );
    } catch (e) {
      CliUI.printError('No se pudo cargar: $e');
    }
  }

  void _printStatus() {
    final vision = VisionSystem.getPlayerVision(_state);

    CliUI.printStatusBar(
      location: _state.currentLocation.name,
      healthNarrative: 'Te sientes ${vision.healthNarrative}',
      manaNarrative: 'Estás ${vision.manaNarrative}',
      turnCount: _state.turnCount,
      mainQuest: _state.mainQuest,
      health: vision.canSeeHealth ? vision.health : null,
      maxHealth: vision.canSeeHealth ? vision.maxHealth : null,
      mana: vision.canSeeMana ? vision.mana : null,
      maxMana: vision.canSeeMana ? vision.maxMana : null,
      attack: vision.canSeeAttack ? vision.attack : null,
      defense: vision.canSeeDefense ? vision.defense : null,
      speed: vision.canSeeSpeed ? vision.speed : null,
    );
  }

  void _printMiniStatus() {
    final vision = VisionSystem.getPlayerVision(_state);
    final locColor = Ansi.cyan;
    final turnColor = Ansi.gray;

    stdout.write('$locColor  📍 ${_state.currentLocation.name}${Ansi.reset}');

    if (vision.canSeeHealth) {
      final hpColor = vision.health / vision.maxHealth > 0.5
          ? Ansi.green
          : Ansi.red;
      stdout.write(
          '  $hpColor❤️ ${vision.health}/${vision.maxHealth}${Ansi.reset}');
    }

    print('$turnColor  [T${_state.turnCount}]${Ansi.reset}');
  }

  void _applyStateChanges(Map<String, dynamic> changes) {
    if (changes.containsKey('itemGained')) {
      final itemName = changes['itemGained'] as String;
      final item = GameItem(
        id: _uuid.v4(),
        name: itemName,
        type: ItemType.misc,
        description: 'Un objeto descubierto durante la aventura',
        createdAt: DateTime.now(),
      );
      final inventory = Map<String, GameItem>.from(_state.inventory);
      inventory[item.id] = item;
      _state = _state.copyWith(inventory: inventory);
      CliUI.printSuccess('Nuevo objeto: $itemName');
    }

    if (changes.containsKey('npcMet')) {
      _state = _state.copyWith(
        keyFacts: [..._state.keyFacts, 'Conoció a: ${changes['npcMet']}'],
      );
    }

    if (changes.containsKey('combat')) {
      final damage = 5 + (_state.turnCount % 10);
      final newHealth =
          (_state.player.health - damage).clamp(1, _state.player.maxHealth);
      _state = _state.copyWith(
        player: _state.player.copyWith(health: newHealth),
      );
    }
  }

  List<String> _inferTags(String input) {
    final lower = input.toLowerCase();
    final tags = <String>[];
    if (_containsAny(lower, ['ataco', 'golpeo', 'peleo', 'lucho', 'disparo'])) {
      tags.add('combat');
    }
    if (_containsAny(lower, ['hablo', 'pregunto', 'digo', 'saludo'])) {
      tags.add('dialogue');
    }
    if (_containsAny(lower, ['exploro', 'busco', 'miro', 'examino', 'investigo'])) {
      tags.add('exploration');
    }
    if (_containsAny(lower, ['camino', 'voy', 'viajo', 'entro', 'salgo'])) {
      tags.add('movement');
    }
    return tags;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  /// Generate initial goal based on character backstory
  Future<String> _generateInitialGoal(Character player) async {
    try {
      final prompt = '''
Genera un objetivo narrativo para una aventura (1 frase).

PERSONAJE:
- ${player.name}, ${player.characterClass ?? 'Aventurero'}
- Historia: ${player.backstory ?? 'Sin historia'}

Debe ser un problema del mundo (robo, amenaza, misterio), concreto y urgente.
Puede conectar con el trasfondo del personaje.

Ejemplo: "El Cristal Lunar fue robado. Recupéralo antes de que desate una maldición"
''';
      
      final response = await _aiService.narrate(prompt: prompt, maxTokens: 100);
      return response.narrative.trim();
    } catch (e) {
      return 'Un misterioso robo amenaza la región. Investiga antes de que sea tarde';
    }
  }

  /// Generate creative opening scene based on character
  Future<String> _generateCreativeOpening(Character player) async {
    try {
      final prompt = '''
Crea el inicio de una aventura original para este personaje.

PERSONAJE:
${player.name}, ${player.characterClass ?? 'Aventurero'}
Historia: ${player.backstory ?? 'Sin historia'}
Personalidad: ${player.personality ?? 'Equilibrado'}

OBJETIVO: ${_state.mainQuest}

REGLAS:
- No uses clichés como encrucijadas o 4 caminos
- Sitúa al personaje en contexto del objetivo
- No narres sus acciones, solo la situación
- Creatividad total en formato

Ejemplo: "Despiertas en una posada. Gritos afuera. Alguien grita sobre un robo en el templo."
''';

      final response = await _aiService.narrate(
        prompt: prompt,
        maxTokens: 1000,
      );
      
      return response.narrative.trim();
    } catch (e) {
      return 'Tu aventura comienza. El objetivo es claro: ${_state.mainQuest}';
    }
  }

  /// Print character summary
  void _printCharacterSummary() {
    final player = _state.player;
    print('${Ansi.brightCyan}╔${'═' * 78}╗${Ansi.reset}');
    print('${Ansi.brightCyan}║${Ansi.reset} ${Ansi.bold}${player.name}${Ansi.reset} - ${Ansi.cyan}${player.characterClass ?? 'Aventurero'}${Ansi.reset}');
    print('${Ansi.brightCyan}╠${'═' * 78}╣${Ansi.reset}');
    if (player.appearance != null) {
      print('${Ansi.brightCyan}║${Ansi.reset} ${Ansi.gray}Apariencia:${Ansi.reset} ${player.appearance}');
    }
    if (player.personality != null) {
      print('${Ansi.brightCyan}║${Ansi.reset} ${Ansi.gray}Personalidad:${Ansi.reset} ${player.personality}');
    }
    if (player.backstory != null) {
      print('${Ansi.brightCyan}║${Ansi.reset} ${Ansi.gray}Historia:${Ansi.reset} ${player.backstory}');
    }
    print('${Ansi.brightCyan}╚${'═' * 78}╝${Ansi.reset}');
  }

  GameState _createInitialState(Character player, String goal) {
    final now = DateTime.now();
    return GameState(
      player: player,
      currentLocation: Location(
        id: _uuid.v4(),
        name: 'Punto de Inicio',
        description: null,  // La IA generará la descripción
        atmosphere: 'Expectante',
        era: 'medieval',
        dangerLevel: 1,
        createdAt: now,
      ),
      era: 'medieval',
      mainQuest: goal,
      keyFacts: [goal],
    );
  }
}