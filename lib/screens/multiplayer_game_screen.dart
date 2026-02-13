import 'package:flutter/material.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/core/services/context_manager.dart';
import 'package:quest_master/core/services/ai_service.dart';
import 'package:quest_master/core/config/ai_config.dart';
import 'package:quest_master/core/services/ai_service_factory.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../services/multiplayer_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/stats_bar.dart';
import '../models/chat_message.dart';

const _uuid = Uuid();

class MultiplayerGameScreen extends StatefulWidget {
  final Character character;
  final String roomCode;
  final bool isHost;

  const MultiplayerGameScreen({
    super.key,
    required this.character,
    required this.roomCode,
    required this.isHost,
  });

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  late AIService _aiService;
  final ContextManager _contextManager = ContextManager();
  final MultiplayerService _multiplayerService = MultiplayerService();
  late GameState _state;
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _myActionController = TextEditingController();
  
  StreamSubscription? _roomSubscription;
  StreamSubscription? _narrativeSubscription;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _myActionSubmitted = false;
  String _partnerAction = '';
  bool _partnerActionSubmitted = false;
  String? _partnerName;
  final Set<int> _processedTurns = {};
  final Set<String> _processedActionPairs = {};  // ← AÑADIDO

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    _aiService = createAIService(provider: AIProvider.groq);

    if (widget.isHost) {
      await _initializeAsHost();
    } else {
      await _initializeAsGuest();
    }

    _scrollToBottom();
    _listenToRoom();
    _listenToNarrative();
  }

  Future<void> _initializeAsHost() async {
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

    await _multiplayerService.saveGameData(
      roomCode: widget.roomCode,
      mainQuest: goal,
      initialNarrative: opening,
    );

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
  }

  Future<void> _initializeAsGuest() async {
    int attempts = 0;
    Map<String, dynamic>? gameData;
    
    while (gameData == null && attempts < 30) {
      await Future.delayed(const Duration(milliseconds: 500));
      gameData = await _multiplayerService.getGameData(widget.roomCode);
      attempts++;
    }

    if (gameData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo cargar la partida'),
            backgroundColor: Color(0xFFe94560),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    final goal = gameData['mainQuest'] as String;
    final opening = gameData['initialNarrative'] as String;

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
  }

  void _listenToRoom() {
    _roomSubscription = _multiplayerService.listenToRoom(widget.roomCode).listen((event) {
      if (!mounted) return;

      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;

      final host = data['host'] as Map<dynamic, dynamic>?;
      final guest = data['guest'] as Map<dynamic, dynamic>?;

      if (host == null || guest == null) return;

      final partner = widget.isHost ? guest : host;
      
      setState(() {
        _partnerName = partner['name'] as String?;
        _partnerAction = partner['currentAction'] as String? ?? '';
        _partnerActionSubmitted = partner['submitted'] as bool? ?? false;
      });

      if (widget.isHost && 
          (host['submitted'] == true) && 
          (guest['submitted'] == true)) {
        _processBothActions(
          host['currentAction'] as String,
          guest['currentAction'] as String,
        );
      }
    });
  }

  void _listenToNarrative() {
    _narrativeSubscription = _multiplayerService.listenToNarrative(widget.roomCode).listen((dbEvent) {
      if (!mounted) return;

      final data = dbEvent.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;

      final turnNumber = data['turnNumber'] as int;
      
      // Check if we've already processed this turn
      if (_processedTurns.contains(turnNumber)) {
        print('🔴 DEBUG [${widget.isHost ? "HOST" : "GUEST"}]: Turn $turnNumber already processed, skipping...');
        return;
      }
      
      // Mark as processed IMMEDIATELY
      _processedTurns.add(turnNumber);
      print('🟢 DEBUG [${widget.isHost ? "HOST" : "GUEST"}]: Processing turn $turnNumber');
      
      final hostAction = data['hostAction'] as String;
      final guestAction = data['guestAction'] as String;
      final narrative = data['narrative'] as String;

      // Add actions and narrative to chat
      setState(() {
        _messages.add(ChatMessage(
          text: '${widget.isHost ? widget.character.name : _partnerName}: $hostAction',
          isPlayer: widget.isHost,
        ));
        _messages.add(ChatMessage(
          text: '${widget.isHost ? _partnerName : widget.character.name}: $guestAction',
          isPlayer: !widget.isHost,
        ));
        _messages.add(ChatMessage(
          text: narrative,
          isPlayer: false,
        ));
        
        _myActionSubmitted = false;
        _isLoading = false;
      });

      _myActionController.clear();

      final gameEvent = GameEvent(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        playerAction: '$hostAction\n$guestAction',
        narrative: narrative,
        stateChanges: {},
        tags: [],
      );

      _state = _state.copyWith(
        events: [..._state.events, gameEvent],
        turnCount: turnNumber,
      );

      _scrollToBottom();
    });
  }

  Future<String> _generateInitialGoal(Character player) async {
    try {
      final prompt = '''
Genera un objetivo narrativo para una aventura cooperativa (1 frase).

PERSONAJES:
- ${player.name}, ${player.characterClass}
- Historia: ${player.backstory}

Debe ser un problema del mundo (robo, amenaza, misterio), concreto y urgente.
Debe requerir cooperación entre dos aventureros.

Ejemplo: "El Cristal Lunar fue robado. Recupérenlo antes de que desate una maldición"
''';

      final response = await _aiService.narrate(prompt: prompt, maxTokens: 100);
      return response.narrative.trim();
    } catch (e) {
      return 'Un misterioso robo amenaza la región. Investiguen antes de que sea tarde';
    }
  }

  Future<String> _generateCreativeOpening(Character player) async {
    try {
      final prompt = '''
Crea el inicio de una aventura cooperativa para DOS personajes.

PERSONAJE 1:
${player.name}, ${player.characterClass}
Historia: ${player.backstory}

OBJETIVO: ${_state.mainQuest}

REGLAS:
- Menciona que hay DOS aventureros trabajando juntos
- No uses clichés como encrucijadas o 4 caminos
- Sitúa a ambos personajes en contexto del objetivo
- No narres sus acciones, solo la situación
- Creatividad total en formato

Ejemplo: "Dos aventureros se encuentran en una posada. Gritos afuera. Alguien grita sobre un robo en el templo."
''';

      final response = await _aiService.narrate(
        prompt: prompt,
        maxTokens: 1000,
      );

      return response.narrative.trim();
    } catch (e) {
      return 'Dos aventureros comienzan su aventura juntos. El objetivo es claro: ${_state.mainQuest}';
    }
  }

  void _submitMyAction() {
    if (_myActionController.text.trim().isEmpty) return;
    if (_myActionSubmitted) return;

    setState(() {
      _myActionSubmitted = true;
    });

    _multiplayerService.updatePlayerAction(
      roomCode: widget.roomCode,
      isHost: widget.isHost,
      action: _myActionController.text.trim(),
      submitted: true,
    );
  }

  Future<void> _processBothActions(String hostAction, String guestAction) async {
    if (!widget.isHost) return;
    if (_isLoading) return;

    // Create unique key for this action pair
    final actionKey = '$hostAction|||$guestAction';
    
    // Check if we've already processed this exact pair of actions
    if (_processedActionPairs.contains(actionKey)) {
      print('🔴 DEBUG [HOST]: Action pair already processed, skipping...');
      return;
    }
    
    // Mark as processed IMMEDIATELY
    _processedActionPairs.add(actionKey);
    print('🟢 DEBUG [HOST]: Processing action pair');

    setState(() {
      _isLoading = true;
    });

    try {
      final combinedAction = '''
${widget.character.name} (${widget.character.characterClass}): $hostAction
${_partnerName ?? 'Compañero'}: $guestAction
''';

      final prompt = _contextManager.buildPrompt(
        state: _state,
        playerInput: combinedAction,
      );

      final response = await _aiService.narrate(
        prompt: prompt,
        maxTokens: 1000,
      );

      await _multiplayerService.saveNarrative(
        roomCode: widget.roomCode,
        hostAction: hostAction,
        guestAction: guestAction,
        narrative: response.narrative,
        turnNumber: _state.turnCount + 1,
      );

      await _multiplayerService.resetTurn(widget.roomCode);

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

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _narrativeSubscription?.cancel();
    _myActionController.dispose();
    _scrollController.dispose();
    _multiplayerService.setConnected(
      roomCode: widget.roomCode,
      isHost: widget.isHost,
      connected: false,
    );
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
                  widget.isHost 
                      ? 'Iniciando aventura cooperativa...'
                      : 'Cargando partida del host...',
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFFe94560),
                    ),
                  ),
                  const Spacer(),
                  if (_partnerName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f3460),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, size: 16, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            _partnerName!,
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ],
                      ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _myActionSubmitted
                            ? const Color(0xFF0f3460)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _myActionSubmitted
                              ? Colors.green
                              : const Color(0xFF0f3460),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _myActionSubmitted ? Icons.check_circle : Icons.edit,
                            size: 16,
                            color: _myActionSubmitted ? Colors.green : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _myActionSubmitted ? 'Listo ✓' : 'Escribiendo...',
                            style: TextStyle(
                              fontSize: 12,
                              color: _myActionSubmitted ? Colors.green : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _partnerActionSubmitted
                            ? const Color(0xFF0f3460)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _partnerActionSubmitted
                              ? Colors.green
                              : const Color(0xFF0f3460),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _partnerActionSubmitted ? Icons.check_circle : Icons.hourglass_empty,
                            size: 16,
                            color: _partnerActionSubmitted ? Colors.green : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _partnerActionSubmitted ? 'Listo ✓' : 'Esperando...',
                            style: TextStyle(
                              fontSize: 12,
                              color: _partnerActionSubmitted ? Colors.green : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      widget.isHost ? 'Narrando...' : 'Esperando narrativa...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1a1a2e).withOpacity(0.0),
                    const Color(0xFF1a1a2e).withOpacity(0.8),
                    const Color(0xFF1a1a2e),
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1a1a2e).withOpacity(0.6),
                            const Color(0xFF0f3460).withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF0f3460).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _myActionController,
                        enabled: !_myActionSubmitted && !_isLoading,
                        decoration: InputDecoration(
                          hintText: _myActionSubmitted
                              ? 'Esperando a tu compañero...'
                              : '¿Qué haces?',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: (!_myActionSubmitted && !_isLoading)
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFe94560),
                                Color(0xFFd13555),
                              ],
                            )
                          : null,
                      color: (_myActionSubmitted || _isLoading) ? Colors.grey[800] : null,
                      shape: BoxShape.circle,
                      boxShadow: (!_myActionSubmitted && !_isLoading)
                          ? [
                              BoxShadow(
                                color: const Color(0xFFe94560).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: IconButton(
                      onPressed: (!_myActionSubmitted && !_isLoading) ? _submitMyAction : null,
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.white,
                      iconSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}