import 'package:flutter_test/flutter_test.dart';
import 'package:quest_master/core/models/prefab.dart';

void main() {
  group('Prefab', () {
    test('toJson and fromJson roundtrip', () {
      final prefab = Prefab(
        id: 'pf-1',
        name: 'Ciudad del Eter Colapsando',
        type: PrefabType.situation,
        description: 'Una ciudad flotante en pleno colapso',
        data: {
          'era': 'steampunk',
          'mainQuest': 'Salvar la ciudad',
          'locationName': 'Ciudad del Eter',
        },
        situationSnapshot: {
          'player': {
            'id': 'p-1',
            'name': 'Heroe',
            'createdAt': '2025-01-01T00:00:00.000',
          },
          'currentLocation': {
            'id': 'l-1',
            'name': 'Ciudad del Eter',
            'createdAt': '2025-01-01T00:00:00.000',
          },
        },
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 15),
        tags: ['steampunk', 'epico', 'ciudad'],
      );

      final json = prefab.toJson();
      final restored = Prefab.fromJson(json);

      expect(restored.id, prefab.id);
      expect(restored.name, prefab.name);
      expect(restored.type, PrefabType.situation);
      expect(restored.description, prefab.description);
      expect(restored.data['era'], 'steampunk');
      expect(restored.situationSnapshot, isNotNull);
      expect(restored.tags.length, 3);
      expect(restored.schemaVersion, 1);
    });

    test('character prefab roundtrip', () {
      final prefab = Prefab(
        id: 'pf-2',
        name: 'Elara la Redentora',
        type: PrefabType.character,
        data: {
          'id': 'char-1',
          'name': 'Elara',
          'title': 'la Redentora',
          'health': 100,
          'maxHealth': 100,
          'attack': 20,
          'defense': 15,
          'createdAt': '2025-01-01T00:00:00.000',
        },
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final json = prefab.toJson();
      final restored = Prefab.fromJson(json);

      expect(restored.type, PrefabType.character);
      expect(restored.data['name'], 'Elara');
      expect(restored.data['attack'], 20);
    });

    test('copyWith updates fields', () {
      final prefab = Prefab(
        id: 'pf-3',
        name: 'Original',
        type: PrefabType.item,
        data: {'name': 'Espada'},
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final updated = prefab.copyWith(
        name: 'Actualizado',
        tags: ['nuevo'],
        updatedAt: DateTime(2025, 2, 1),
      );

      expect(updated.id, prefab.id); // ID unchanged
      expect(updated.name, 'Actualizado');
      expect(updated.tags, ['nuevo']);
      expect(updated.type, PrefabType.item); // Type unchanged
    });
  });
}
