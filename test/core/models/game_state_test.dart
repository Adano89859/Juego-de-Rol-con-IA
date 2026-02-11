import 'package:flutter_test/flutter_test.dart';
import 'package:quest_master/core/models/models.dart';

void main() {
  group('GameState', () {
    late GameState state;

    setUp(() {
      state = GameState(
        player: Character(
          id: 'player-1',
          name: 'Heroe',
          createdAt: DateTime(2025, 1, 1),
        ),
        currentLocation: Location(
          id: 'loc-1',
          name: 'Plaza Central',
          createdAt: DateTime(2025, 1, 1),
        ),
        events: List.generate(
          15,
          (i) => GameEvent(
            id: 'evt-$i',
            timestamp: DateTime(2025, 1, 1, i),
            playerAction: 'Accion $i',
            narrative: 'Resultado $i',
          ),
        ),
      );
    });

    test('recentEvents returns correct subset', () {
      final recent = state.recentEvents(5);
      expect(recent.length, 5);
      expect(recent.first.id, 'evt-10');
      expect(recent.last.id, 'evt-14');
    });

    test('recentEvents returns all if count > total', () {
      final all = state.recentEvents(100);
      expect(all.length, 15);
    });

    test('vision checks work with player innate vision', () {
      expect(state.playerHasSelfVision, false);
      expect(state.playerHasEnemyVision, false);
      expect(state.playerHasItemVision, false);

      final withVision = state.copyWith(
        player: state.player.copyWith(hasSelfVision: true),
      );
      expect(withVision.playerHasSelfVision, true);
    });

    test('vision checks work with equipped vision items', () {
      final visionItem = GameItem(
        id: 'eye-1',
        name: 'Ojo de Verdad',
        type: ItemType.vision,
        grantsSelfVision: true,
        isEquipped: true,
        createdAt: DateTime(2025, 1, 1),
      );

      final withItem = state.copyWith(
        inventory: {'eye-1': visionItem},
      );
      expect(withItem.playerHasSelfVision, true);
      expect(withItem.playerHasEnemyVision, false);
    });

    test('unequipped vision items do not grant vision', () {
      final visionItem = GameItem(
        id: 'eye-1',
        name: 'Ojo de Verdad',
        type: ItemType.vision,
        grantsSelfVision: true,
        isEquipped: false, // not equipped
        createdAt: DateTime(2025, 1, 1),
      );

      final withItem = state.copyWith(
        inventory: {'eye-1': visionItem},
      );
      expect(withItem.playerHasSelfVision, false);
    });

    test('toJson and fromJson roundtrip', () {
      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.player.name, state.player.name);
      expect(restored.currentLocation.name, state.currentLocation.name);
      expect(restored.events.length, state.events.length);
      expect(restored.era, state.era);
    });
  });
}
