import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../pages/alerts_page.dart';
import '../pages/history_page.dart';
import '../theme/app_theme.dart';

enum HistoryView { parameters, alerts }

/// The title of the History and Alerts pages, as a pill that switches
/// between the two.
class HistoryViewPill extends StatelessWidget {
  const HistoryViewPill({super.key, required this.current});

  final HistoryView current;

  static String _label(AppLocalizations l10n, HistoryView view) => switch (view) {
    HistoryView.parameters => l10n.historyTitle,
    HistoryView.alerts => l10n.alertsTitle,
  };

  static IconData _icon(HistoryView view) => switch (view) {
    HistoryView.parameters => Icons.show_chart,
    HistoryView.alerts => Icons.notifications_none,
  };

  void _open(BuildContext context, HistoryView view) {
    if (view == current) return;
    // Swapped in place (not stacked) so Back still leaves the history area.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => switch (view) {
          HistoryView.parameters => const HistoryPage(),
          HistoryView.alerts => const AlertsPage(),
        },
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    return PopupMenuButton<HistoryView>(
      tooltip: '',
      position: PopupMenuPosition.under,
      onSelected: (view) => _open(context, view),
      itemBuilder: (_) => [
        for (final view in HistoryView.values)
          PopupMenuItem(
            value: view,
            child: Row(
              children: [
                Icon(_icon(view), size: 20, color: palette.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(_label(l10n, view))),
                if (view == current) Icon(Icons.check, size: 18, color: palette.primary),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 9, 10, 9),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.primary.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _label(l10n, current),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: palette.textPrimary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: palette.primary),
          ],
        ),
      ),
    );
  }
}
