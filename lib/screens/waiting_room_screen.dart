import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_master/core/models/models.dart';
import '../services/multiplayer_service.dart';
import 'multiplayer_game_screen.dart';
import 'dart:async';

class WaitingRoomScreen extends StatefulWidget {
  final Character character;
  final String roomCode;
  final bool isHost;

  const WaitingRoomScreen({
    super.key,
    required this.character,
    required this.roomCode,
    required this.isHost,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final MultiplayerService _multiplayerService = MultiplayerService();
  StreamSubscription? _roomSubscription;
  bool _isConnected = false;
  String? _partnerName;

  @override
  void initState() {
    super.initState();
    _initializeRoom();
  }

  Future<void> _initializeRoom() async {
    if (widget.isHost) {
      // Create room
      await _multiplayerService.createRoom(
        roomCode: widget.roomCode,
        hostCharacter: widget.character,
      );
    } else {
      // Join room
      final success = await _multiplayerService.joinRoom(
        roomCode: widget.roomCode,
        guestCharacter: widget.character,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo unir a la sala. Verifica el código.'),
              backgroundColor: Color(0xFFe94560),
            ),
          );
          Navigator.pop(context);
        }
        return;
      }
    }

    // Listen to room changes
    _roomSubscription = _multiplayerService.listenToRoom(widget.roomCode).listen((event) {
      if (!mounted) return;

      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;

      final host = data['host'] as Map<dynamic, dynamic>?;
      final guest = data['guest'] as Map<dynamic, dynamic>?;

      // Check if both players are connected
      if (host != null && guest != null) {
        setState(() {
          _isConnected = true;
          _partnerName = widget.isHost ? guest['name'] : host['name'];
        });

        // Navigate to game after 1 second
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MultiplayerGameScreen(
                  character: widget.character,
                  roomCode: widget.roomCode,
                  isHost: widget.isHost,
                ),
              ),
            );
          }
        });
      }
    });
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado al portapapeles'),
        backgroundColor: Color(0xFF0f3460),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    
    // Disconnect from room
    _multiplayerService.setConnected(
      roomCode: widget.roomCode,
      isHost: widget.isHost,
      connected: false,
    );
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.hourglass_empty,
                      size: 80,
                      color: _isConnected ? Colors.green : const Color(0xFFe94560),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isConnected
                          ? '¡Conectado!'
                          : (widget.isHost ? 'Esperando Jugador...' : 'Conectando...'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_isConnected && _partnerName != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Compañero: $_partnerName',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),

                    // Room code display
                    if (widget.isHost) ...[
                      const Text(
                        'Código de Sala:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1a1a2e).withOpacity(0.8),
                              const Color(0xFF0f3460).withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFe94560).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.roomCode,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                color: Color(0xFFe94560),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _copyCode,
                              icon: const Icon(Icons.copy),
                              label: const Text('Copiar Código'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0f3460),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Comparte este código con tu compañero',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Loading indicator
                    if (!_isConnected)
                      const CircularProgressIndicator(
                        color: Color(0xFFe94560),
                      ),

                    const SizedBox(height: 60),

                    // Cancel button
                    if (!_isConnected)
                      TextButton.icon(
                        onPressed: () {
                          if (widget.isHost) {
                            _multiplayerService.deleteRoom(widget.roomCode);
                          }
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Cancelar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}