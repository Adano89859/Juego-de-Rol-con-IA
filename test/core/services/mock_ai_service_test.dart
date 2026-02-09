import 'package:flutter_test/flutter_test.dart';
import 'package:quest_master/core/services/mock_ai_service.dart';

void main() {
  group('MockAIService', () {
    late MockAIService service;

    setUp(() {
      service = MockAIService();
    });

    test('isAvailable returns true', () async {
      expect(await service.isAvailable(), true);
    });

    test('modelName returns mock identifier', () {
      expect(service.modelName, 'mock-narrative-v1');
    });

    test('narrate returns combat response for attack actions', () async {
      final response = await service.narrate(
        prompt: 'El jugador dice: ataco al goblin',
      );

      expect(response.narrative, isNotEmpty);
      expect(response.tokensUsed, greaterThan(0));
    });

    test('narrate returns dialogue response for talk actions', () async {
      final response = await service.narrate(
        prompt: 'El jugador dice: hablo con el mercader',
      );

      expect(response.narrative, isNotEmpty);
    });

    test('narrate returns exploration response for explore actions', () async {
      final response = await service.narrate(
        prompt: 'El jugador dice: exploro la cueva',
      );

      expect(response.narrative, isNotEmpty);
    });

    test('narrate returns default response for unknown actions', () async {
      final response = await service.narrate(
        prompt: 'El jugador dice: medito en silencio',
      );

      expect(response.narrative, isNotEmpty);
    });

    test('summarize returns a summary string', () async {
      final summary = await service.summarize(
        prompt: 'Resume estos eventos...',
      );

      expect(summary, isNotEmpty);
      expect(summary, contains('aventurero'));
    });

    test('generateEntity returns structured data', () async {
      final character = await service.generateEntity(
        prompt: 'Genera un NPC misterioso',
        entityType: 'character',
      );

      expect(character['name'], isNotEmpty);
      expect(character['description'], isNotEmpty);

      final item = await service.generateEntity(
        prompt: 'Genera un artefacto',
        entityType: 'item',
      );

      expect(item['name'], isNotEmpty);

      final location = await service.generateEntity(
        prompt: 'Genera unas ruinas',
        entityType: 'location',
      );

      expect(location['name'], isNotEmpty);
    });
  });
}
