import 'package:flutter/material.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/core/services/context_manager.dart';
import 'package:quest_master/core/services/ai_service.dart';
import 'package:quest_master/core/config/ai_config.dart';
import 'package:quest_master/core/services/ai_service_factory.dart';
import 'package:uuid/uuid.dart';
import '../widgets/message_bubble.dart';
import '../widgets/stats_bar.dart';
import '../widgets/input_bar.dart';
import '../models/chat_message.dart';  // ← AÑADIDO

const _uuid = Uuid();

class GameScreen extends StatefulWidget {
  final Character character;
  final bool isMultiplayer;

  const GameScreen({
    super.key,
    required this.character,
    this.isMultiplayer = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late AIService _aiService;
  final ContextManager _contextManager = ContextManager();
  late GameState _state;
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    _aiService = createAIService(provider: AIProvider.groq);

    final goal = await _generateInitialGoal(widget.character);

    final now = DateTime.now();
    _state = GameState(
      player: widget.character,
      currentLocation: Location(
        id: _uuid.v4(),
        name: 'Inicio de la Aventura',
        description: null,
        atmosphere: 'Expectante',
        era: 'medieval',
        dangerLevel: 1,
        createdAt: now,
      ),
      era: 'medieval',
      mainQuest: goal,
      keyFacts: [goal],
    );

    final opening = await _generateCreativeOpening(widget.character);

    setState(() {
      _messages.add(ChatMessage(
        text: '🎯 $goal',
        isPlayer: false,
        isSystem: true,
      ));
      _messages.add(ChatMessage(
        text: opening,
        isPlayer: false,
      ));
      _isInitialized = true;
    });

    _scrollToBottom();
  }

  Future<String> _generateInitialGoal(Character player) async {
    try {
      final prompt = '''
Genera un objetivo narrativo para una aventura (1 frase).

PERSONAJE:
- ${player.name}, ${player.characterClass}
- Historia: ${player.backstory}

Debe ser un problema del mundo (robo, amenaza, misterio), concreto y urgente.

Ejemplo: "El Cristal Lunar fue robado. Recupéralo antes de que desate una maldición"
''';

      final response = await _aiService.narrate(prompt: prompt, maxTokens: 100);
      return response.narrative.trim();
    } catch (e) {
      return 'Un misterioso robo amenaza la región. Investiga antes de que sea tarde';
    }
  }

  Future<String> _generateCreativeOpening(Character player) async {
    try {
      final prompt = '''
Crea el inicio de una aventura original para este personaje.

PERSONAJE:
${player.name}, ${player.characterClass}
Historia: ${player.backstory}

OBJETIVO: ${_state.mainQuest}

REGLAS:
- No uses clichés como encrucijadas o 4 caminos
- Sitúa al personaje en contexto del objetivo
- No narres sus acciones, solo la situación
- Creatividad total en formato

Ejemplo: "Despiertas en una posada. Gritos afuera. Alguien grita sobre un robo en el templo."
''';

      final response = await _aiService.narrate(
        prompt: prompt,
        maxTokens: 1000,
      );

      return response.narrative.trim();
    } catch (e) {
      return 'Tu aventura comienza. El objetivo es claro: ${_state.mainQuest}';
    }
  }

  Future<void> _handleAction(String action) async {
    if (action.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: action, isPlayer: true));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final prompt = _contextManager.buildPrompt(
        state: _state,
        playerInput: action,
      );

      final response = await _aiService.narrate(
        prompt: prompt,
        maxTokens: 1000,
      );

      final event = GameEvent(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        playerAction: action,
        narrative: response.narrative,
        stateChanges: response.stateChanges,
        tags: [],
      );

      _state = _state.copyWith(
        events: [..._state.events, event],
        turnCount: _state.turnCount + 1,
      );

      setState(() {
        _messages.add(ChatMessage(
          text: response.narrative,
          isPlayer: false,
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '❌ Error de conexión. Verifica tu API key de Groq.',
          isPlayer: false,
          isSystem: true,
        ));
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a1a2e),
                const Color(0xFF0f3460).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFe94560).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.help_outline,
                    color: Color(0xFFe94560),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ayuda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.white70,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Cómo jugar:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFe94560),
                ),
              ),
              const SizedBox(height: 12),
              _HelpItem(
                icon: Icons.edit,
                text: 'Escribe lo que quieres hacer en el campo de texto',
              ),
              _HelpItem(
                icon: Icons.send,
                text: 'La IA narrará las consecuencias de tus acciones',
              ),
              _HelpItem(
                icon: Icons.person,
                text: 'Tú decides TODO: movimientos, diálogos, acciones',
              ),
              const SizedBox(height: 16),
              const Text(
                'Ejemplos de acciones:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              _ExampleAction(text: 'Hablo con el anciano sobre la misión'),
              _ExampleAction(text: 'Examino la habitación en busca de pistas'),
              _ExampleAction(text: 'Voy hacia el bosque del norte'),
              _ExampleAction(text: 'Intento convencer al guardia'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f3460).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFFe94560),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Escribe con naturalidad, como si hablaras con un narrador',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0f3460),
                const Color(0xFF16213e),
                const Color(0xFF1a1a2e),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFFe94560),
                ),
                const SizedBox(height: 24),
                Text(
                  'Iniciando aventura...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0f3460),
              const Color(0xFF16213e),
              const Color(0xFF1a1a2e),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0f3460),
                    const Color(0xFF16213e).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    '⚔️ QUEST MASTER',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFFe94560),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _showHelp,
                    icon: const Icon(Icons.help_outline),
                    color: Colors.white70,
                    tooltip: 'Ayuda',
                  ),
                ],
              ),
            ),
            StatsBar(state: _state),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return MessageBubble(message: _messages[index]);
                },
              ),
            ),
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFFe94560),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Narrando...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            InputBar(
              onSubmit: _handleAction,
              enabled: !_isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

// ← CLASE ChatMessage ELIMINADA (ahora está en chat_message.dart)

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFFe94560),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleAction extends StatelessWidget {
  final String text;

  const _ExampleAction({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0f3460).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFe94560).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        '› $text',
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white70,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}