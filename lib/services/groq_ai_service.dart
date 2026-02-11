import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/services/ai_service.dart';

/// Servicio de IA usando Groq API (LLaMA 3.3 70B)
class GroqAIService implements AIService {
  final String apiKey;
  final String model;
  
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _timeout = Duration(seconds: 30);
  
  GroqAIService({
    required this.apiKey,
    this.model = 'llama-3.3-70b-versatile',
  });
  
  @override
  String get modelName => model;
  
  @override
  Future<bool> isAvailable() async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'user', 'content': 'test'}
              ],
              'max_tokens': 1,
            }),
          )
          .timeout(_timeout);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<AIResponse> narrate({
    required String prompt,
    int maxTokens = 500,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'system', 'content': _narrativeSystemPrompt},
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.8,
              'max_tokens': maxTokens,
              'top_p': 1,
              'stream': false,
            }),
          )
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        final tokensUsed = data['usage']?['total_tokens'] as int? ?? 0;
        
        // Try to extract state changes if the AI included them
        final stateChanges = _extractStateChanges(content);
        
        return AIResponse(
          narrative: _cleanNarrative(content),
          stateChanges: stateChanges,
          tokensUsed: tokensUsed,
        );
      } else {
        throw Exception(
          'Groq API error (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con Groq: $e');
    }
  }
  
  @override
  Future<String> summarize({
    required String prompt,
    int maxTokens = 150,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {
                  'role': 'system',
                  'content': 'Resume los siguientes eventos de una aventura en 2-3 frases concisas:'
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.5,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        // Fallback: simple truncation
        return prompt.length > 200 
            ? '${prompt.substring(0, 200)}...' 
            : prompt;
      }
    } catch (e) {
      // Fallback
      return prompt.length > 200 
          ? '${prompt.substring(0, 200)}...' 
          : prompt;
    }
  }
  
  @override
  Future<Map<String, dynamic>> generateEntity({
    required String prompt,
    required String entityType,
    int maxTokens = 300,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {
                  'role': 'system',
                  'content': 'Genera un $entityType en formato JSON basado en la descripción. '
                      'Responde SOLO con JSON válido, sin texto adicional.'
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.9,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Try to parse as JSON
        try {
          final cleaned = _cleanJsonResponse(content);
          return jsonDecode(cleaned) as Map<String, dynamic>;
        } catch (e) {
          // If not valid JSON, return basic structure
          return {
            'name': 'Entidad Generada',
            'description': content,
            'type': entityType,
          };
        }
      }
    } catch (e) {
      // Return minimal entity
      return {
        'name': 'Entidad Generada',
        'description': 'Error al generar: $e',
        'type': entityType,
      };
    }
    
    return {};
  }
  
  // ── Helpers ──
  
  String get _narrativeSystemPrompt => '''
Eres el narrador de "Quest Master", una aventura épica e interactiva.

REGLAS IMPORTANTES:
1. Narra de forma épica, envolvente y descriptiva
2. Valida si las acciones son físicamente posibles
3. Si algo es imposible, explica por qué pero sugiere alternativas
4. Mantén consistencia con la historia previa
5. Genera consecuencias lógicas de las acciones
6. Sé creativo pero realista dentro del mundo
7. Responde en 2-4 párrafos máximo (sé conciso)

Responde SOLO con la narrativa, sin meta-comentarios.
''';
  
  String _cleanNarrative(String content) {
    // Remove any JSON blocks or meta-text
    var cleaned = content;
    
    // Remove markdown code blocks
    cleaned = cleaned.replaceAll(RegExp(r'```json.*?```', dotAll: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'```.*?```', dotAll: true), '');
    
    return cleaned.trim();
  }
  
  Map<String, dynamic> _extractStateChanges(String content) {
    final changes = <String, dynamic>{};
    
    // Try to find JSON blocks
    final jsonMatch = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true)
        .firstMatch(content);
    
    if (jsonMatch != null) {
      try {
        final jsonStr = jsonMatch.group(1);
        if (jsonStr != null) {
          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          changes.addAll(data);
        }
      } catch (e) {
        // Ignore JSON parse errors
      }
    }
    
    return changes;
  }
  
  String _cleanJsonResponse(String content) {
    // Remove markdown code blocks
    var cleaned = content.trim();
    cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');
    return cleaned.trim();
  }
}
