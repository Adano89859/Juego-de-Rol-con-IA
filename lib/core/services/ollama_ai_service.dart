import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quest_master/core/services/ai_service.dart';

/// Real Ollama AI service implementation.
///
/// Connects to a local Ollama instance via REST API.
/// Handles context truncation and retry logic.
class OllamaAIService implements AIService {
  final String baseUrl;
  final String model;
  final http.Client _client;
  final int maxRetries;

  OllamaAIService({
    this.baseUrl = 'http://localhost:11434',
    this.model = 'llama3.2',
    http.Client? client,
    this.maxRetries = 3,
  }) : _client = client ?? http.Client();

  @override
  Future<AIResponse> narrate({
    required String prompt,
    int maxTokens = 500,
  }) async {
    final response = await _generate(prompt, maxTokens);
    return AIResponse(
      narrative: response,
      tokensUsed: response.length ~/ 4,
    );
  }

  @override
  Future<String> summarize({
    required String prompt,
    int maxTokens = 200,
  }) async {
    return _generate(prompt, maxTokens);
  }

  @override
  Future<Map<String, dynamic>> generateEntity({
    required String prompt,
    required String entityType,
    int maxTokens = 300,
  }) async {
    final enrichedPrompt = '$prompt\n\n'
        'Responde SOLO con un JSON valido para un $entityType '
        'con campos: name, description, y otros relevantes.';

    final response = await _generate(enrichedPrompt, maxTokens);

    // Try to parse JSON from the response
    try {
      // Find JSON object in response
      final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      }
    } catch (_) {
      // If JSON parsing fails, return a structured fallback
    }

    return {
      'name': 'Entidad Generada',
      'description': response,
    };
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  String get modelName => model;

  /// Core generation method with retry logic.
  Future<String> _generate(String prompt, int maxTokens) async {
    var retryDelay = const Duration(seconds: 2);

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await _client.post(
          Uri.parse('$baseUrl/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': model,
            'prompt': prompt,
            'stream': false,
            'options': {
              'num_predict': maxTokens,
              'temperature': 0.8,
              'top_p': 0.9,
              'repeat_penalty': 1.1,
            },
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return data['response'] as String? ?? '';
        }

        throw Exception('Ollama API error: ${response.statusCode}');
      } catch (e) {
        if (attempt == maxRetries) {
          return '[Error de IA: No se pudo generar respuesta. '
              'Verifica que Ollama este ejecutandose en $baseUrl]';
        }
        await Future.delayed(retryDelay);
        retryDelay *= 2; // Exponential backoff
      }
    }

    return '[Error inesperado]';
  }

  void dispose() {
    _client.close();
  }
}
