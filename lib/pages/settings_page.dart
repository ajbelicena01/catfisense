import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/alert_preferences.dart';
import '../services/auth_service.dart';
import '../services/language_controller.dart';
import '../services/pond_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../utils/logout.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/account_dialogs.dart';
import '../widgets/app_header.dart';
import '../widgets/rename_pond_dialog.dart';
import '../widgets/sms_recipients_card.dart';
import 'about_page.dart';

// Same red the drawer uses for its Logout item.
const _kDangerColor = Color(0xFFF95668);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = context.l10n;
    final theme = context.watch<ThemeController>();
    final alerts = context.watch<AlertPreferences>();
    final language = context.watch<LanguageController>();

    return Scaffold(
      backgroundColor: palette.background,
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(current: BottomNavTab.settings),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    l10n.settingsTitle,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: palette.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  const _AccountSection(),
                  const SizedBox(height: 24),
                  _SectionLabel(l10n.settingsAppearance, palette: palette),
                  _SettingsCard(
                    palette: palette,
                    children: [
                      _SwitchRow(
                        icon: Icons.dark_mode_outlined,
                        label: l10n.settingsDarkMode,
                        subtitle: l10n.settingsDarkModeHint,
                        value: theme.isDarkMode,
                        palette: palette,
                        onChanged: theme.setDarkMode,
                      ),
                      Divider(height: 1, color: palette.divider),
                      _TextSizeControl(theme: theme, palette: palette),
                      Divider(height: 1, color: palette.divider),
                      _NavRow(
                        icon: Icons.language,
                        label: l10n.settingsLanguage,
                        subtitle: languageName(l10n, language.languageCode),
                        palette: palette,
                        onTap: () => pickLanguage(context, language),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(l10n.settingsNotifications, palette: palette),
                  _SettingsCard(
                    palette: palette,
                    children: [
                      _SwitchRow(
                        icon: Icons.notifications_outlined,
                        label: l10n.settingsPush,
                        subtitle: l10n.settingsPushHint,
                        value: alerts.pushEnabled,
                        palette: palette,
                        onChanged: alerts.setPushEnabled,
                      ),
                      Divider(height: 1, color: palette.divider),
                      _SwitchRow(
                        icon: Icons.sms_outlined,
                        label: l10n.settingsSms,
                        subtitle: l10n.settingsSmsHint,
                        value: alerts.smsEnabled,
                        palette: palette,
                        onChanged: alerts.setSmsEnabled,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(l10n.settingsAbout, palette: palette),
                  _SettingsCard(
                    palette: palette,
                    children: [
                      _NavRow(
                        icon: Icons.info_outline,
                        label: l10n.settingsAboutApp,
                        subtitle: l10n.settingsAboutAppHint,
                        palette: palette,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AboutPage()),
                        ),
                      ),
                    ],
                  ),
                  // Kept last and apart from the other rows so it isn't hit
                  // by accident; it still asks for confirmation.
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => confirmAndLogout(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kDangerColor,
                        backgroundColor: palette.surface,
                        side: const BorderSide(color: _kDangerColor, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(l10n.logoutConfirm, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Who is logged in and their pond role; for the pond's owner, also the
/// caretaker and the pond code they can share, change, or use to invite.
class _AccountSection extends StatefulWidget {
  const _AccountSection();

  @override
  State<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<_AccountSection> {
  final _authService = AuthService();
  final _pondService = PondService();
  late final Stream<PondMembership?> _membership;
  Stream<PondDetails>? _details;
  String? _detailsPondId;
  Stream<String?>? _name;
  String? _namePondId;

  @override
  void initState() {
    super.initState();
    final uid = _authService.currentUser?.uid;
    _membership = uid == null ? Stream.value(null) : _pondService.membership(uid);
  }

  Stream<PondDetails> _detailsFor(String pondId) {
    if (_detailsPondId != pondId) {
      _detailsPondId = pondId;
      _details = _pondService.pondDetails(pondId);
    }
    return _details!;
  }

  Stream<String?> _nameFor(String pondId) {
    if (_namePondId != pondId) {
      _namePondId = pondId;
      _name = _pondService.pondName(pondId);
    }
    return _name!;
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = context.l10n;
    return StreamBuilder<PondMembership?>(
      stream: _membership,
      builder: (context, snapshot) {
        final membership = snapshot.data;
        final (roleLabel, roleSubtitle) = switch (membership?.role) {
          PondRole.owner => (l10n.settingsRoleOwner, l10n.settingsRoleOwnerHint),
          PondRole.caretaker => (l10n.roleCaretaker, l10n.settingsRoleCaretakerHint),
          null => (l10n.settingsRole, snapshot.hasData ? l10n.settingsRoleNone : l10n.commonChecking),
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionLabel(l10n.settingsAccount, palette: palette),
            _SettingsCard(
              palette: palette,
              children: [
                _NavRow(
                  icon: Icons.person_outline,
                  label: l10n.settingsLoggedInAs,
                  subtitle: _authService.currentPhoneDigits ?? l10n.settingsUnknownNumber,
                  palette: palette,
                ),
                Divider(height: 1, color: palette.divider),
                _NavRow(
                  icon: membership?.role == PondRole.owner ? Icons.verified_user_outlined : Icons.badge_outlined,
                  label: roleLabel,
                  subtitle: roleSubtitle,
                  palette: palette,
                ),
                if (membership != null) ...[
                  Divider(height: 1, color: palette.divider),
                  _PondNameRow(
                    pondId: membership.pondId,
                    name: _nameFor(membership.pondId),
                    canRename: membership.role == PondRole.owner,
                    palette: palette,
                  ),
                ],
              ],
            ),
            if (membership?.role == PondRole.owner) ...[
              const SizedBox(height: 24),
              _PondMembersSection(
                pondId: membership!.pondId,
                details: _detailsFor(membership.pondId),
                pondService: _pondService,
              ),
              const SizedBox(height: 24),
              _SectionLabel(l10n.smsTitle, palette: palette),
              SmsRecipientsCard(pondId: membership.pondId),
            ],
          ],
        );
      },
    );
  }
}

/// The pond's name; the owner can tap it to rename the pond.
class _PondNameRow extends StatelessWidget {
  const _PondNameRow({required this.pondId, required this.name, required this.canRename, required this.palette});

  final String pondId;
  final Stream<String?> name;
  final bool canRename;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<String?>(
      stream: name,
      builder: (context, snapshot) {
        final current = snapshot.data;
        return _NavRow(
          icon: Icons.water_outlined,
          label: l10n.pondNameLabel,
          subtitle: current ?? (snapshot.hasData || snapshot.hasError ? l10n.pondNameNotSet : l10n.commonLoading),
          palette: palette,
          onTap: canRename && snapshot.connectionState == ConnectionState.active
              ? () => showRenamePondDialog(context, pondId: pondId, currentName: current)
              : null,
          trailing: canRename ? Icon(Icons.edit_outlined, color: palette.primary, size: 20) : null,
        );
      },
    );
  }
}

enum _RemoveChoice { remove, removeAndChangeCode }

class _PondMembersSection extends StatelessWidget {
  const _PondMembersSection({required this.pondId, required this.details, required this.pondService});

  final String pondId;
  final Stream<PondDetails> details;
  final PondService pondService;

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: PondService.formatCode(code)));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.membersCodeCopied)));
    }
  }

  Future<void> _changeCode(BuildContext context, String? oldCode) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final code = await pondService.changeCode(pondId: pondId, oldCode: oldCode);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          code == null
              ? l10n.membersChangeCodeError
              : l10n.membersNewCode(PondService.formatCode(code)),
        ),
      ),
    );
  }

  Future<void> _confirmChangeCode(BuildContext context, String? oldCode) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.membersChangeCodeTitle),
        content: Text(
          oldCode == null
              ? l10n.membersChangeCodeBodyUnknown
              : l10n.membersChangeCodeBody(PondService.formatCode(oldCode)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.membersChangeCodeConfirm)),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await _changeCode(context, oldCode);
  }

  Future<void> _confirmRemove(BuildContext context, PondDetails pond) async {
    final l10n = context.l10n;
    final who = pond.caretakerName ?? pond.caretakerPhone ?? l10n.membersTheCaretaker;
    final choice = await showDialog<_RemoveChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.membersRemoveTitle),
        content: Text(l10n.membersRemoveBody(who)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(_RemoveChoice.remove),
            child: Text(l10n.membersRemove),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(_RemoveChoice.removeAndChangeCode),
            child: Text(l10n.membersRemoveAndChange),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final removed = await pondService.removeCaretaker(
      pondId: pondId,
      caretakerUid: pond.caretakerUid!,
      label: pond.caretakerPhone,
    );
    messenger.showSnackBar(SnackBar(content: Text(removed ? l10n.membersRemoved : l10n.membersRemoveError)));
    if (!removed) return;
    if (choice == _RemoveChoice.removeAndChangeCode && context.mounted) {
      await _changeCode(context, pond.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = context.l10n;
    return StreamBuilder<PondDetails>(
      stream: details,
      builder: (context, snapshot) {
        final pond = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionLabel(l10n.membersTitle, palette: palette),
            _SettingsCard(
              palette: palette,
              children: pond == null
                  ? [
                      _NavRow(
                        icon: Icons.group_outlined,
                        label: l10n.membersTitle,
                        subtitle: snapshot.hasError ? l10n.membersLoadError : l10n.commonLoading,
                        palette: palette,
                      ),
                    ]
                  : [
                      if (pond.caretakerUid == null)
                        _NavRow(
                          icon: Icons.person_add_alt,
                          label: l10n.membersNoCaretaker,
                          subtitle: l10n.membersInviteHint,
                          palette: palette,
                        )
                      else
                        _NavRow(
                          icon: Icons.person_outline,
                          label: l10n.roleCaretaker,
                          subtitle: [?pond.caretakerName, pond.caretakerPhone ?? l10n.membersNoPhone].join(' · '),
                          palette: palette,
                          trailing: TextButton(
                            onPressed: () => _confirmRemove(context, pond),
                            style: TextButton.styleFrom(foregroundColor: _kDangerColor),
                            child: Text(l10n.membersRemove, style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      Divider(height: 1, color: palette.divider),
                      _NavRow(
                        icon: Icons.vpn_key_outlined,
                        label: l10n.pondCodeField,
                        subtitle: pond.code == null ? l10n.membersNoCode : PondService.formatCode(pond.code!),
                        palette: palette,
                        trailing: pond.code == null
                            ? null
                            : IconButton(
                                tooltip: l10n.membersCopyCode,
                                onPressed: () => _copyCode(context, pond.code!),
                                icon: Icon(Icons.copy, color: palette.primary, size: 20),
                              ),
                      ),
                      Divider(height: 1, color: palette.divider),
                      _NavRow(
                        icon: Icons.autorenew,
                        label: l10n.membersChangeCode,
                        subtitle: l10n.membersChangeCodeHint,
                        palette: palette,
                        onTap: () => _confirmChangeCode(context, pond.code),
                      ),
                    ],
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.palette});

  final String text;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textSecondary),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.palette});

  final List<Widget> children;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(children: children),
    );
  }
}

class _TextSizeControl extends StatelessWidget {
  const _TextSizeControl({required this.theme, required this.palette});

  final ThemeController theme;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [l10n.textSizeSmall, l10n.textSizeDefault, l10n.textSizeLarge, l10n.textSizeExtraLarge];
    final index = ((theme.textScale - minAppTextScale) / 0.15).round().clamp(0, labels.length - 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: palette.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.settingsTextSize,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: palette.textPrimary),
                ),
              ),
              Text(labels[index], style: TextStyle(fontSize: 13, color: palette.textSecondary)),
            ],
          ),
          Semantics(
            label: l10n.settingsTextSize,
            value: labels[index],
            child: Slider(
              min: minAppTextScale,
              max: maxAppTextScale,
              divisions: 3,
              value: theme.textScale,
              label: labels[index],
              onChanged: theme.setTextScale,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A', style: TextStyle(fontSize: 13, color: palette.textSecondary)),
              Text('A', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: palette.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A tappable (or, without [onTap], read-only) row in a settings card.
/// [trailing] replaces the chevron, e.g. with a button.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.palette,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final AppPalette palette;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: palette.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: palette.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right, color: palette.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.palette,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final AppPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: palette.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: palette.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, activeThumbColor: palette.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}
