import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/core/utils/vision_system.dart';
import 'package:quest_master/shared/widgets/narrative_bubble.dart';
import 'package:quest_master/shared/widgets/stat_bar.dart';

void main() {
  group('StatBar Widget', () {
    testWidgets('shows narrative when stats are hidden', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatBar(
              label: 'Salud',
              current: 75,
              max: 100,
              narrative: 'Te sientes ligeramente herido',
              revealed: false,
              icon: Icons.favorite,
            ),
          ),
        ),
      );

      expect(find.text('Te sientes ligeramente herido'), findsOneWidget);
      expect(find.text('Salud: 75/100'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows numbers and bar when stats are revealed',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatBar(
              label: 'Salud',
              current: 75,
              max: 100,
              narrative: 'Te sientes ligeramente herido',
              revealed: true,
              icon: Icons.favorite,
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(find.text('Salud: 75/100'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Te sientes ligeramente herido'), findsNothing);
    });
  });

  group('NarrativeBubble Widget', () {
    testWidgets('renders player action bubble', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NarrativeBubble(
              text: 'Ataco al goblin',
              isPlayerAction: true,
            ),
          ),
        ),
      );

      expect(find.text('Ataco al goblin'), findsOneWidget);
      expect(find.text('Tu accion:'), findsOneWidget);
    });

    testWidgets('renders narrative bubble without action label',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NarrativeBubble(
              text: 'El goblin cae derrotado ante tu poder.',
              isPlayerAction: false,
            ),
          ),
        ),
      );

      expect(
        find.text('El goblin cae derrotado ante tu poder.'),
        findsOneWidget,
      );
      expect(find.text('Tu accion:'), findsNothing);
    });
  });

  group('Vision System Integration', () {
    test('hidden stats scenario - no vision items', () {
      final state = GameState(
        player: Character(
          id: 'p-1',
          name: 'Heroe',
          health: 45,
          maxHealth: 100,
          createdAt: DateTime(2025, 1, 1),
        ),
        currentLocation: Location(
          id: 'l-1',
          name: 'Test',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final vision = VisionSystem.getPlayerVision(state);
      expect(vision.canSeeHealth, false);
      expect(vision.healthNarrative, 'gravemente herido');
    });

    test('revealed stats scenario - with Ojo de Verdad equipped', () {
      final state = GameState(
        player: Character(
          id: 'p-1',
          name: 'Heroe',
          health: 45,
          maxHealth: 100,
          createdAt: DateTime(2025, 1, 1),
        ),
        currentLocation: Location(
          id: 'l-1',
          name: 'Test',
          createdAt: DateTime(2025, 1, 1),
        ),
        inventory: {
          'eye-1': GameItem(
            id: 'eye-1',
            name: 'Ojo de Verdad',
            type: ItemType.vision,
            grantsSelfVision: true,
            isEquipped: true,
            createdAt: DateTime(2025, 1, 1),
          ),
        },
      );

      final vision = VisionSystem.getPlayerVision(state);
      expect(vision.canSeeHealth, true);
      expect(vision.health, 45);
      expect(vision.maxHealth, 100);
    });
  });
}
