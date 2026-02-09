/// Response from the AI service containing narrative and state changes.
class AIResponse {
  final String narrative;
  final Map<String, dynamic> stateChanges;
  final int tokensUsed;

  const AIResponse({
    required this.narrative,
    this.stateChanges = const {},
    this.tokensUsed = 0,
  });
}

/// Abstract AI service interface.
///
/// Implementations:
/// - [MockAIService]: For development/testing with predefined responses
/// - [OllamaAIService]: Real Ollama integration
///
/// All implementations must handle context limits gracefully.
abstract class AIService {
  /// Generate a narrative response to the player's action.
  Future<AIResponse> narrate({
    required String prompt,
    int maxTokens,
  });

  /// Summarize a list of events into a compact paragraph.
  Future<String> summarize({
    required String prompt,
    int maxTokens,
  });

  /// Generate a new entity (NPC, item, location) from a description.
  Future<Map<String, dynamic>> generateEntity({
    required String prompt,
    required String entityType,
    int maxTokens,
  });

  /// Check if the service is available and responsive.
  Future<bool> isAvailable();

  /// Get the model name being used.
  String get modelName;
}
