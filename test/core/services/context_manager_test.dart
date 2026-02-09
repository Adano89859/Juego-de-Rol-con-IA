import 'package:flutter_test/flutter_test.dart';
import 'package:quest_master/core/constants/game_constants.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/core/services/context_manager.dart';

void main() {
  group('ContextManager', () {
    late ContextManager manager;
    late GameState state;

    setUp(() {
      manager = ContextManager();
      state = GameState(
        player: Character(
          id: 'p-1',
          name: 'Arthas',
          title: 'el Errante',
          health: 75,
          maxHealth: 100,
          attack: 15,
          defense: 10,
          mana: 40,
          maxMana: 50,
          abilities: ['Golpe de Trueno'],
          createdAt: DateTime(2025, 1, 1),
        ),
        currentLocation: Location(
          id: 'loc-1',
          name: 'Bosque Oscuro',
          description: 'Un bosque denso donde la luz apenas penetra',
          atmosphere: 'Ominoso',
          createdAt: DateTime(2025, 1, 1),
        ),
        storySummary: 'Arthas escapo del castillo y se adentro en el bosque.',
        keyFacts: [
          'Porta la Espada Sagrada',
          'El Rey le debe un favor',
          'La profecia menciona su nombre',
        ],
        mainQuest: 'Encontrar el Templo Perdido',
        events: [
          GameEvent(
            id: 'e-1',
            timestamp: DateTime(2025, 1, 1, 10),
            playerAction: 'Examino los arboles',
            narrative: 'Los arboles tienen marcas extrañas talladas.',
          ),
          GameEvent(
            id: 'e-2',
            timestamp: DateTime(2025, 1, 1, 11),
            playerAction: 'Sigo las marcas',
            narrative: 'Las marcas te guian hacia un claro en el bosque.',
          ),
        ],
        era: 'medieval',
      );
    });

    test('buildPrompt includes all sections', () {
      final prompt = manager.buildPrompt(
        state: state,
        playerInput: 'Entro al claro',
      );

      // System instructions
      expect(prompt, contains('narrador'));
      expect(prompt, contains('medieval'));

      // Story summary
      expect(prompt, contains('Arthas escapo'));

      // Key facts
      expect(prompt, contains('Espada Sagrada'));
      expect(prompt, contains('Rey'));

      // Main quest
      expect(prompt, contains('Templo Perdido'));

      // Recent events
      expect(prompt, contains('Examino los arboles'));
      expect(prompt, contains('Sigo las marcas'));

      // Current state
      expect(prompt, contains('Bosque Oscuro'));
      expect(prompt, contains('Arthas'));

      // Player input
      expect(prompt, contains('Entro al claro'));

      // Response instructions
      expect(prompt, contains('Narra el resultado'));
    });

    test('buildPrompt stays within token budget', () {
      final prompt = manager.buildPrompt(
        state: state,
        playerInput: 'Ataco al dragon',
      );

      final tokens = GameConstants.estimateTokens(prompt);
      // Should be well under the max context tokens
      expect(tokens, lessThan(GameConstants.maxContextTokens));
    });

    test('needsSummarization detects threshold', () {
      expect(manager.needsSummarization(state), false);

      // Create state with many events
      final manyEvents = List.generate(
        30,
        (i) => GameEvent(
          id: 'e-$i',
          timestamp: DateTime(2025, 1, 1, i),
          playerAction: 'Accion $i',
          narrative: 'Resultado $i',
        ),
      );

      final bigState = state.copyWith(events: manyEvents);
      expect(manager.needsSummarization(bigState), true);
    });

    test('buildSummarizationPrompt includes events', () {
      final prompt = manager.buildSummarizationPrompt(state.events);

      expect(prompt, contains('Resume'));
      expect(prompt, contains('Examino los arboles'));
      expect(prompt, contains('Sigo las marcas'));
    });

    test('extractKeyFacts adds new facts from events', () {
      final events = [
        GameEvent(
          id: 'e-new',
          timestamp: DateTime.now(),
          playerAction: 'Recojo el amuleto',
          narrative: 'Encontraste un amuleto antiguo',
          stateChanges: {'itemGained': 'Amuleto Antiguo'},
        ),
      ];

      final facts = manager.extractKeyFacts(
        ['Hecho existente'],
        events,
      );

      expect(facts, contains('Hecho existente'));
      expect(facts, contains('Obtuvo: Amuleto Antiguo'));
    });

    test('extractKeyFacts limits total count', () {
      final existingFacts =
          List.generate(20, (i) => 'Hecho $i');

      final facts = manager.extractKeyFacts(existingFacts, []);

      expect(facts.length, GameConstants.maxKeyFacts);
    });

    test('prompt handles empty state gracefully', () {
      final emptyState = GameState(
        player: Character(
          id: 'p-1',
          name: 'Nadie',
          createdAt: DateTime(2025, 1, 1),
        ),
        currentLocation: Location(
          id: 'l-1',
          name: 'Vacio',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final prompt = manager.buildPrompt(
        state: emptyState,
        playerInput: 'Miro alrededor',
      );

      expect(prompt, isNotEmpty);
      expect(prompt, contains('Miro alrededor'));
    });
  });
}
