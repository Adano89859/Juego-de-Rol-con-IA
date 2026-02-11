import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_master/features/game/providers/game_providers.dart';

/// Free-form text input for player actions.
///
/// The player can type anything - the AI handles interpretation.
class ActionInput extends ConsumerStatefulWidget {
  const ActionInput({super.key});

  @override
  ConsumerState<ActionInput> createState() => _ActionInputState();
}

class _ActionInputState extends ConsumerState<ActionInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitAction() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(gameStateProvider.notifier).processAction(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = ref.watch(isProcessingProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !isProcessing,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitAction(),
                decoration: InputDecoration(
                  hintText: isProcessing
                      ? 'La historia se escribe...'
                      : '¿Que haces? (escribe cualquier accion)',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    isProcessing ? Icons.hourglass_top : Icons.edit_note,
                    color: theme.colorScheme.primary,
                  ),
                ),
                maxLines: 2,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            _buildSendButton(context, isProcessing),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, bool isProcessing) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: IconButton.filled(
        onPressed: isProcessing ? null : _submitAction,
        icon: isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
