import 'package:flutter_test/flutter_test.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/core/utils/vision_system.dart';

void main() {
  group('VisionSystem', () {
    late GameState baseState;

    setUp(() {
      baseState = GameState(
        player: Character(
          id: 'p-1',
          name: 'Heroe',
          health: 75,
          maxHealth: 100,
          attack: 15,
          defense: 10,
          speed: 12,
          luck: 8,
          mana: 30,
          maxMana: 50,
          createdAt: DateTime(2025, 1, 1),
        ),
        currentLocation: Location(
          id: 'l-1',
          name: 'Test',
          createdAt: DateTime(2025, 1, 1),
        ),
      );
    });

    group('Player Vision', () {
      test('stats hidden by default', () {
        final vision = VisionSystem.getPlayerVision(baseState);

        expect(vision.canSeeHealth, false);
        expect(vision.canSeeAttack, false);
        expect(vision.canSeeDefense, false);
        expect(vision.canSeeMana, false);
        // But narrative is always available
        expect(vision.healthNarrative, isNotEmpty);
        expect(vision.manaNarrative, isNotEmpty);
        // Values exist internally
        expect(vision.health, 75);
        expect(vision.maxHealth, 100);
      });

      test('stats revealed with innate self vision', () {
        final state = baseState.copyWith(
          player: baseState.player.copyWith(hasSelfVision: true),
        );
        final vision = VisionSystem.getPlayerVision(state);

        expect(vision.canSeeHealth, true);
        expect(vision.canSeeAttack, true);
        expect(vision.canSeeDefense, true);
        expect(vision.health, 75);
        expect(vision.attack, 15);
      });

      test('stats revealed with equipped Ojo de Verdad', () {
        final trueEye = GameItem(
          id: 'eye-1',
          name: 'Ojo de Verdad',
          type: ItemType.vision,
          grantsSelfVision: true,
          isEquipped: true,
          createdAt: DateTime(2025, 1, 1),
        );

        final state = baseState.copyWith(
          inventory: {'eye-1': trueEye},
        );
        final vision = VisionSystem.getPlayerVision(state);

        expect(vision.canSeeHealth, true);
        expect(vision.canSeeAttack, true);
      });

      test('unequipped vision items dont grant sight', () {
        final trueEye = GameItem(
          id: 'eye-1',
          name: 'Ojo de Verdad',
          type: ItemType.vision,
          grantsSelfVision: true,
          isEquipped: false, // NOT equipped
          createdAt: DateTime(2025, 1, 1),
        );

        final state = baseState.copyWith(
          inventory: {'eye-1': trueEye},
        );
        final vision = VisionSystem.getPlayerVision(state);

        expect(vision.canSeeHealth, false);
      });
    });

    group('Character (NPC/Enemy) Vision', () {
      test('enemy stats hidden without enemy vision', () {
        final enemy = Character(
          id: 'e-1',
          name: 'Goblin',
          health: 30,
          maxHealth: 30,
          attack: 8,
          defense: 3,
          createdAt: DateTime(2025, 1, 1),
        );

        final vision = VisionSystem.getCharacterVision(baseState, enemy);

        expect(vision.canSeeStats, false);
        expect(vision.name, 'Goblin');
        expect(vision.healthNarrative, isNotEmpty);
        // Values exist but UI should not show them
        expect(vision.health, 30);
      });

      test('enemy stats revealed with enemy vision', () {
        final mysticVision = GameItem(
          id: 'mv-1',
          name: 'Vision Mistica',
          type: ItemType.vision,
          grantsEnemyVision: true,
          isEquipped: true,
          createdAt: DateTime(2025, 1, 1),
        );

        final state = baseState.copyWith(
          inventory: {'mv-1': mysticVision},
        );

        final enemy = Character(
          id: 'e-1',
          name: 'Dragon',
          health: 500,
          maxHealth: 500,
          attack: 50,
          defense: 30,
          createdAt: DateTime(2025, 1, 1),
        );

        final vision = VisionSystem.getCharacterVision(state, enemy);

        expect(vision.canSeeStats, true);
        expect(vision.health, 500);
        expect(vision.attack, 50);
      });
    });

    group('Item Vision', () {
      test('item properties hidden without item vision', () {
        final sword = GameItem(
          id: 's-1',
          name: 'Espada Misteriosa',
          type: ItemType.weapon,
          attackBonus: 15,
          rarity: 'rare',
          effects: ['Daño de fuego'],
          createdAt: DateTime(2025, 1, 1),
        );

        final vision = VisionSystem.getItemVision(baseState, sword);

        expect(vision.canSeeProperties, false);
        expect(vision.name, 'Espada Misteriosa');
        // Values exist but UI should not show numbers
        expect(vision.attackBonus, 15);
      });

      test('item properties revealed with analysis glasses', () {
        final glasses = GameItem(
          id: 'g-1',
          name: 'Gafas de Analisis',
          type: ItemType.vision,
          grantsItemVision: true,
          isEquipped: true,
          createdAt: DateTime(2025, 1, 1),
        );

        final state = baseState.copyWith(
          inventory: {'g-1': glasses},
        );

        final sword = GameItem(
          id: 's-1',
          name: 'Espada Misteriosa',
          type: ItemType.weapon,
          attackBonus: 15,
          rarity: 'rare',
          createdAt: DateTime(2025, 1, 1),
        );

        final vision = VisionSystem.getItemVision(state, sword);

        expect(vision.canSeeProperties, true);
        expect(vision.attackBonus, 15);
        expect(vision.rarity, 'rare');
      });
    });
  });
}
