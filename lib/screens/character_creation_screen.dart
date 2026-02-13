import 'package:flutter/material.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:uuid/uuid.dart';
import 'game_mode_screen.dart';

const _uuid = Uuid();

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  int _step = 0;
  final _nameController = TextEditingController();
  final _backstoryController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _personalityController = TextEditingController();
  
  String _selectedClass = 'Mago';
  final List<String> _classes = [
    'Mago',
    'Guerrero',
    'Pícaro',
    'Clérigo',
    'Explorador',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _backstoryController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      _finishCreation();
    }
  }

  void _previousStep() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  void _finishCreation() {
    final character = Character(
      id: _uuid.v4(),
      name: _nameController.text.trim().isEmpty ? 'Aventurero' : _nameController.text.trim(),
      characterClass: _selectedClass,
      backstory: _backstoryController.text.trim().isEmpty ? 'Un aventurero misterioso' : _backstoryController.text.trim(),
      appearance: _appearanceController.text.trim().isEmpty ? 'Aspecto común' : _appearanceController.text.trim(),
      personality: _personalityController.text.trim().isEmpty ? 'Equilibrado' : _personalityController.text.trim(),
      health: 100,
      maxHealth: 100,
      mana: 100,
      maxMana: 100,
      attack: 10,
      defense: 8,
      speed: 12,
      luck: 10,
      createdAt: DateTime.now(),
    );

    // Navegar a la pantalla de selección de modo
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameModeScreen(character: character),
      ),
    );
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
                    // Title
                    const Text(
                      '⚔️ QUEST MASTER',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Color(0xFFe94560),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Creación de Personaje',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _step
                                ? const Color(0xFFe94560)
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 40),

                    // Step content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildStep(),
                    ),

                    const SizedBox(height: 40),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_step > 0)
                          TextButton.icon(
                            onPressed: _previousStep,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Atrás'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                          )
                        else
                          const SizedBox(),
                        ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFe94560),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(_step < 4 ? 'Siguiente' : 'Comenzar Aventura'),
                        ),
                      ],
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

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildNameStep();
      case 1:
        return _buildClassStep();
      case 2:
        return _buildBackstoryStep();
      case 3:
        return _buildAppearanceStep();
      case 4:
        return _buildPersonalityStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildNameStep() {
    return _StepCard(
      key: const ValueKey(0),
      title: '¿Cómo te llamas?',
      child: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          hintText: 'Ingresa tu nombre',
          prefixIcon: Icon(Icons.person),
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildClassStep() {
    return _StepCard(
      key: const ValueKey(1),
      title: '¿Qué clase eres?',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: _classes.map((className) {
          final isSelected = _selectedClass == className;
          return ChoiceChip(
            label: Text(className),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _selectedClass = className);
            },
            selectedColor: const Color(0xFFe94560),
            backgroundColor: const Color(0xFF1a1a2e),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBackstoryStep() {
    return _StepCard(
      key: const ValueKey(2),
      title: '¿Cuál es tu pasado?',
      subtitle: 'Describe tu historia en 2-3 líneas',
      child: TextField(
        controller: _backstoryController,
        decoration: const InputDecoration(
          hintText: 'Ej: Fui aprendiz de un mago que desapareció...',
        ),
        maxLines: 3,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAppearanceStep() {
    return _StepCard(
      key: const ValueKey(3),
      title: '¿Cómo te ves?',
      subtitle: 'Describe tu apariencia física',
      child: TextField(
        controller: _appearanceController,
        decoration: const InputDecoration(
          hintText: 'Ej: Elfo de cabello plateado, ojos violetas...',
        ),
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPersonalityStep() {
    return _StepCard(
      key: const ValueKey(4),
      title: '¿Qué te caracteriza?',
      subtitle: 'Describe tu personalidad',
      child: TextField(
        controller: _personalityController,
        decoration: const InputDecoration(
          hintText: 'Ej: Curioso, impulsivo, leal...',
        ),
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _StepCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e).withOpacity(0.8),
            const Color(0xFF0f3460).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFe94560).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}