import '../config/ai_config.dart';
import 'ai_service.dart';
import 'mock_ai_service.dart';
import '../../services/groq_ai_service.dart';

/// Factory para crear el servicio de IA apropiado
AIService createAIService({AIProvider? provider}) {
  final selectedProvider = provider ?? AIConfig.provider;
  
  switch (selectedProvider) {
    case AIProvider.mock:
      return MockAIService();
      
    case AIProvider.groq:
      if (AIConfig.groqApiKey == 'PONER_TU_KEY_AQUI') {
        throw Exception(
          'API Key de Groq no configurada. '
          'Edita lib/core/config/ai_config.dart y coloca tu API key real',
        );
      }
      return GroqAIService(
        apiKey: AIConfig.groqApiKey,
        model: AIConfig.groqModel,
      );
  }
}

/// Obtener nombre legible del proveedor
String getProviderName(AIProvider provider) {
  switch (provider) {
    case AIProvider.mock:
      return 'Mock AI (Testing)';
    case AIProvider.groq:
      return 'Groq AI (${AIConfig.groqModel})';
  }
}
