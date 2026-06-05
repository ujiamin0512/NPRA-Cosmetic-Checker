import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputField extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final bool obscureText;
  final String? label;
  final ValueChanged<String>? onChanged;

  const PinInputField({
    super.key,
    required this.controller,
    this.length = 6,
    this.obscureText = true,
    this.label,
    this.onChanged,
  });

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  final FocusNode _focusNode = FocusNode();
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final String text = widget.controller.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label!,
                style: const TextStyle(
                  color: Color(0xFF333752),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF8A8DA4),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Hidden TextField underneath to handle text entry and copy-paste
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          maxLength: widget.length,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(widget.length),
                          ],
                          onChanged: widget.onChanged,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    // 6 PIN Styled boxes (Non-focusable list)
                    IgnorePointer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(widget.length, (index) {
                          final bool isFocused = _focusNode.hasFocus && index == text.length;
                          final bool hasValue = index < text.length;
                          String character = '';
                          if (hasValue) {
                            character = _obscureText ? '•' : text[index];
                          }

                          return Container(
                            width: widget.label == null ? 40 : 46, // Slightly smaller if row has eye icon to prevent overflow
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFocused
                                    ? const Color(0xFF1D0CC2) // Active theme color
                                    : hasValue
                                        ? const Color(0xFFD0D7FF) // Theme light blue border
                                        : const Color(0xFFE0E0E0), // Grey border
                                width: isFocused ? 2.5 : 1.5,
                              ),
                              boxShadow: isFocused
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF1D0CC2).withAlpha(38), // ~15% opacity
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              character,
                              style: TextStyle(
                                fontSize: _obscureText && hasValue ? 28 : 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D0CC2), // Text theme color
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.label == null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF8A8DA4),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
