import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final bool enabled;

  const InputBar({
    super.key,
    required this.onSubmit,
    this.enabled = true,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSubmit(_controller.text.trim());
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                controller: _controller,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  hintText: '¿Qué haces?',
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
                onSubmitted: (_) => _submit(),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: widget.enabled
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFe94560),
                        Color(0xFFd13555),
                      ],
                    )
                  : null,
              color: widget.enabled ? null : Colors.grey[800],
              shape: BoxShape.circle,
              boxShadow: widget.enabled
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
              onPressed: widget.enabled ? _submit : null,
              icon: const Icon(Icons.send_rounded),
              color: Colors.white,
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}