import 'dart:math';

import 'package:quest_master/core/services/ai_service.dart';

/// Mock AI service for development and testing.
///
/// Provides believable narrative responses without requiring
/// an actual AI model. Useful for:
/// - Sandbox development without Ollama
/// - Unit/widget testing
/// - Offline mode fallback
class MockAIService implements AIService {
  final _random = Random();

  // Narrative templates organized by action keywords
  static const _combatResponses = [
    'Tu golpe conecta con fuerza. El enemigo retrocede, tambaleandose. '
        'Un hilo de sangre oscura cae al suelo. La batalla continua, '
        'pero puedes ver que tu oponente esta debilitandose.',
    'Te lanzas al ataque con determinacion. Tu arma silba en el aire '
        'y encuentra su objetivo. El impacto resuena en el campo de batalla. '
        'Tu enemigo gruñe de dolor pero se mantiene en pie, preparando su contraataque.',
    'Con un movimiento rapido, ejecutas un ataque certero. '
        'La criatura aulla de dolor y retrocede varios pasos. '
        'Aprovechas el momento para reposicionarte estrategicamente.',
  ];

  static const _explorationResponses = [
    'Avanzas con cautela por el sendero. La luz se filtra entre las hojas, '
        'creando patrones danzantes en el suelo. A lo lejos, puedes distinguir '
        'lo que parece ser una estructura antigua, parcialmente cubierta por la vegetacion.',
    'Exploras los alrededores con curiosidad. Encuentras marcas extrañas '
        'en las paredes, simbolos que parecen contar una historia olvidada. '
        'Un sonido distante llama tu atencion hacia el norte.',
    'El camino se bifurca ante ti. A la izquierda, un sendero oscuro '
        'se adentra en la espesura. A la derecha, puedes ver la luz del sol '
        'iluminando lo que parece ser un claro. El viento trae consigo '
        'un aroma dulce y misterioso.',
  ];

  static const _dialogueResponses = [
    'El personaje te mira con interes. "He oido hablar de ti", dice con '
        'voz grave. "Las noticias viajan rapido por estos caminos. '
        'Quizas podamos ayudarnos mutuamente... si estas dispuesto a escuchar."',
    '"Bienvenido, viajero", te saluda con una reverencia. '
        '"Estos son tiempos dificiles. La gente necesita heroes, '
        'y tu tienes aspecto de alguien que busca aventura. '
        'Tengo una propuesta que podria interesarte."',
    'Te observa con ojos penetrantes antes de hablar. '
        '"No eres de por aqui, ¿verdad? Puedo verlo en tu mirada. '
        'Hay algo que deberias saber sobre este lugar... '
        'algo que los demas prefieren olvidar."',
  ];

  static const _defaultResponses = [
    'Realizas tu accion con determinacion. El mundo a tu alrededor '
        'parece responder a tu voluntad. Algo ha cambiado, quizas de forma '
        'sutil, pero puedes sentirlo en el ambiente.',
    'El resultado de tu decision se hace evidente de inmediato. '
        'Nuevas posibilidades se abren ante ti, mientras las consecuencias '
        'de tus acciones comienzan a tomar forma.',
    'Tu accion tiene un efecto inmediato en el entorno. '
        'Puedes percibir como el mundo se adapta y reacciona. '
        'La aventura continua, y cada paso te acerca mas a tu destino.',
  ];

  static const _itemDiscoveryResponses = [
    'Entre los escombros, algo brilla con un destello peculiar. '
        'Te acercas y descubres un objeto que parece tener cierto poder. '
        'Lo examinas cuidadosamente antes de guardarlo.',
    'Un objeto llama tu atencion. Parece estar fuera de lugar aqui, '
        'como si alguien lo hubiera dejado intencionalmente. '
        'Sientes una energia extraña emanando de el.',
  ];

  @override
  Future<AIResponse> narrate({
    required String prompt,
    int maxTokens = 500,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(
      Duration(milliseconds: 500 + _random.nextInt(1000)),
    );

    final lowerPrompt = prompt.toLowerCase();
    String narrative;
    final stateChanges = <String, dynamic>{};

    if (_containsAny(lowerPrompt, ['ataco', 'golpeo', 'peleo', 'lucho'])) {
      narrative = _randomFrom(_combatResponses);
      stateChanges['combat'] = true;
    } else if (_containsAny(lowerPrompt, ['hablo', 'pregunto', 'digo'])) {
      narrative = _randomFrom(_dialogueResponses);
      stateChanges['dialogue'] = true;
    } else if (_containsAny(
        lowerPrompt, ['exploro', 'busco', 'miro', 'examino', 'investigo'])) {
      narrative = _randomFrom(_explorationResponses);
      // Random chance to find an item
      if (_random.nextDouble() > 0.6) {
        narrative += '\n\n${_randomFrom(_itemDiscoveryResponses)}';
        stateChanges['itemGained'] = 'Objeto misterioso';
      }
    } else {
      narrative = _randomFrom(_defaultResponses);
    }

    return AIResponse(
      narrative: narrative,
      stateChanges: stateChanges,
      tokensUsed: narrative.length ~/ 4,
    );
  }

  @override
  Future<String> summarize({
    required String prompt,
    int maxTokens = 200,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return 'El aventurero ha recorrido un largo camino, '
        'enfrentando desafios y descubriendo secretos del mundo. '
        'Las decisiones tomadas han moldeado el curso de la historia.';
  }

  @override
  Future<Map<String, dynamic>> generateEntity({
    required String prompt,
    required String entityType,
    int maxTokens = 300,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    switch (entityType) {
      case 'character':
        return {
          'name': 'Forastero Misterioso',
          'description': 'Una figura envuelta en sombras',
          'personality': 'Enigmatico y cauteloso',
          'currentMood': 'observador',
        };
      case 'item':
        return {
          'name': 'Amuleto Antiguo',
          'description': 'Un amuleto que emana energia arcana',
          'type': 'artifact',
          'rarity': 'rare',
        };
      case 'location':
        return {
          'name': 'Ruinas Olvidadas',
          'description': 'Restos de una civilizacion perdida',
          'atmosphere': 'Misterioso y silencioso',
          'dangerLevel': 5,
        };
      default:
        return {
          'name': 'Entidad Desconocida',
          'description': 'Algo que desafia la comprension',
        };
    }
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  String get modelName => 'mock-narrative-v1';

  // Helpers

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  String _randomFrom(List<String> list) {
    return list[_random.nextInt(list.length)];
  }
}
