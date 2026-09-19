import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Same as [LabeledTextField] but follows the active theme's colors instead
/// of always being [kBrandOrange] — for the Settings area.
class ThemedLabeledTextField extends StatefulWidget {
  const ThemedLabeledTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  State<ThemedLabeledTextField> createState() => _ThemedLabeledTextFieldState();
}

class _ThemedLabeledTextFieldState extends State<ThemedLabeledTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: TextStyle(fontSize: 15, color: palette.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefixIcon: Icon(widget.icon, color: palette.primary, size: 20),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
            border: UnderlineInputBorder(borderSide: BorderSide(color: palette.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: palette.primary, width: 1.5)),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: palette.primary,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
