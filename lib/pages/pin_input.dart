import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/app_buttons.dart';
import '../widgets/section_heading.dart';

class PinInputPage extends StatefulWidget {
  const PinInputPage({
    super.key,
    required this.uid,
    required this.phoneNumber,
    required this.isSetup,
    required this.onUnlocked,
    required this.onForgotPin,
  });

  final String uid;
  final String phoneNumber;
  final bool isSetup;
  final VoidCallback onUnlocked;
  final VoidCallback onForgotPin;

  @override
  State<PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<PinInputPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _firstPin;
  bool _busy = false;
  Duration? _lockout;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _refreshLockout();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _refreshLockout() async {
    if (widget.isSetup) return;
    final remaining = await SecurePinStore.instance.remainingLockout(widget.uid);
    if (!mounted) return;
    setState(() => _lockout = remaining);
    _lockoutTimer?.cancel();
    if (remaining != null) {
      _lockoutTimer = Timer(remaining, _refreshLockout);
    }
  }

  Future<void> _submit() async {
    if (_controller.text.length != 4 || _busy) return;
    final pin = _controller.text;
    setState(() => _busy = true);

    if (widget.isSetup) {
      if (_firstPin == null) {
        _firstPin = pin;
        _controller.clear();
        setState(() => _busy = false);
        return;
      }
      if (_firstPin != pin) {
        _firstPin = null;
        _controller.clear();
        setState(() => _busy = false);
        _message('PINs did not match. Start again.');
        return;
      }
      await SecurePinStore.instance.setPin(widget.uid, pin);
      if (!mounted) return;
      widget.onUnlocked();
      return;
    }

    final valid = await SecurePinStore.instance.verify(widget.uid, pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _controller.clear();
    });
    if (valid) {
      widget.onUnlocked();
      return;
    }

    await _refreshLockout();
    if (mounted && _lockout == null) _message('Incorrect PIN. Try again.');
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final setupTitle = _firstPin == null ? 'Create your PIN' : 'Confirm your PIN';
    final title = widget.isSetup ? setupTitle : 'Enter your PIN';
    final subtitle = widget.isSetup
        ? 'Choose a four-digit PIN to unlock CatFiSense on this device.'
        : 'Enter your four-digit app PIN.';

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AspectRatio(
              aspectRatio: 402 / 346,
              child: Image.asset('assets/images/wave_top.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              children: [
                Image.asset('assets/images/logo.png', width: 210, height: 90, fit: BoxFit.contain),
                const SizedBox(height: 32),
                SectionHeading(text: title, centered: true),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: palette.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 32),
                Semantics(
                  label: 'Four digit PIN',
                  child: GestureDetector(
                    onTap: _focusNode.requestFocus,
                    child: SizedBox(
                      height: 58,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              final filled = index < _controller.text.length;
                              return Container(
                                width: 54,
                                height: 54,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: palette.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _focusNode.hasFocus && index == _controller.text.length
                                        ? palette.primary
                                        : palette.border,
                                    width: 1.4,
                                  ),
                                ),
                                child: Text(
                                  filled ? '•' : '',
                                  style: TextStyle(fontSize: 28, color: palette.textPrimary),
                                ),
                              );
                            }),
                          ),
                          TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            maxLength: 4,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(color: Colors.transparent, fontSize: 1),
                            cursorColor: Colors.transparent,
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                if (_lockout != null) ...[
                  Text(
                    'Too many attempts. Try again in ${_lockout!.inMinutes + 1} minutes, or verify your phone to reset your PIN.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledActionButton(
                  label: _busy ? 'PLEASE WAIT' : widget.isSetup && _firstPin == null ? 'CONTINUE' : 'CONFIRM PIN',
                  onPressed: _busy || _lockout != null ? null : _submit,
                  isLoading: _busy,
                ),
                if (!widget.isSetup) ...[
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: _busy ? null : widget.onForgotPin,
                    child: Text('Forgot PIN? Verify your phone to reset it', style: TextStyle(color: palette.primary)),
                  ),
                ],
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    widget.phoneNumber,
                    style: TextStyle(fontSize: 13, color: palette.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
