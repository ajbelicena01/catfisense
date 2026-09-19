import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.text, this.centered = false});

  final String text;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2A2A2A)),
        ),
        const SizedBox(height: 6),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(color: kBrandOrange, borderRadius: BorderRadius.circular(2)),
        ),
      ],
    );
  }
}
