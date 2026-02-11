import 'package:flutter_test/flutter_test.dart';
import 'package:quest_master/core/models/character.dart';

void main() {
  group('Character', () {
    late Character character;

    setUp(() {
      character = Character(
        id: 'test-1',
        name: 'Elara',
        title: 'la Redentora',
        health: 80,
        maxHealth: 100,
        attack: 15,
        defense: 10,
        speed: 12,
        luck: 8,
        mana: 30,
        maxMana: 50,
        description: 'Una guerrera valiente',
        personality: 'Determinada y compasiva',
        abilities: ['Golpe Sagrado', 'Escudo de Luz'],
        motivations: ['Proteger a los inocentes'],
        fears: ['La oscuridad interior'],
        createdAt: DateTime(2025, 1, 1),
      );
    });

    test('healthNarrative returns correct description based on HP ratio', () {
      // 80/100 = 0.8 => ligeramente herido
      expect(character.healthNarrative, 'ligeramente herido');

      final critical = character.copyWith(health: 10);
      expect(critical.healthNarrative, 'al borde de la muerte');

      final healthy = character.copyWith(health: 95);
      expect(healthy.healthNarrative, 'en perfecto estado');

      final wounded = character.copyWith(health: 50);
      expect(wounded.healthNarrative, 'herido');

      final grave = character.copyWith(health: 30);
      expect(grave.healthNarrative, 'gravemente herido');

      final brink = character.copyWith(health: 15);
      expect(brink.healthNarrative, 'al borde de la muerte');

      final dying = character.copyWith(health: 5);
      expect(dying.healthNarrative, 'agonizando');
    });

    test('manaNarrative returns correct description', () {
      // 30/50 = 0.6 => con reservas de poder
      expect(character.manaNarrative, 'con reservas de poder');

      final full = character.copyWith(mana: 45);
      expect(full.manaNarrative, 'rebosante de energía mística');

      final low = character.copyWith(mana: 15);
      expect(low.manaNarrative, 'con poca energía mágica');

      final empty = character.copyWith(mana: 5);
      expect(empty.manaNarrative, 'agotado mágicamente');
    });

    test('toJson and fromJson roundtrip preserves all fields', () {
      final json = character.toJson();
      final restored = Character.fromJson(json);

      expect(restored.id, character.id);
      expect(restored.name, character.name);
      expect(restored.title, character.title);
      expect(restored.health, character.health);
      expect(restored.maxHealth, character.maxHealth);
      expect(restored.attack, character.attack);
      expect(restored.defense, character.defense);
      expect(restored.speed, character.speed);
      expect(restored.luck, character.luck);
      expect(restored.mana, character.mana);
      expect(restored.maxMana, character.maxMana);
      expect(restored.description, character.description);
      expect(restored.personality, character.personality);
      expect(restored.abilities, character.abilities);
      expect(restored.motivations, character.motivations);
      expect(restored.fears, character.fears);
      expect(restored.hasSelfVision, false);
      expect(restored.hasEnemyVision, false);
      expect(restored.hasItemVision, false);
    });

    test('copyWith creates correct copy', () {
      final updated = character.copyWith(
        health: 50,
        hasSelfVision: true,
        abilities: ['Golpe Sagrado', 'Escudo de Luz', 'Curacion'],
      );

      expect(updated.health, 50);
      expect(updated.hasSelfVision, true);
      expect(updated.abilities.length, 3);
      // Unchanged fields
      expect(updated.name, 'Elara');
      expect(updated.attack, 15);
    });

    test('toContextString produces compact representation', () {
      final ctx = character.toContextString();
      expect(ctx, contains('Elara'));
      expect(ctx, contains('la Redentora'));
      expect(ctx, contains('HP:80/100'));
      expect(ctx, contains('Golpe Sagrado'));
    });

    test('equality is based on id', () {
      final same = character.copyWith(name: 'Different Name');
      expect(character, equals(same));

      final different = Character(
        id: 'test-2',
        name: 'Elara',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(character, isNot(equals(different)));
    });
  });
}
