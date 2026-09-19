import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu, color: palette.primary),
              ),
              Expanded(
                child: Center(child: Image.asset('assets/images/logo_header.png', height: 64)),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Divider(height: 1, color: palette.divider),
      ],
    );
  }
}
