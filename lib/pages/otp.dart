import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/section_heading.dart';

const _resendCountdownSeconds = 60;

/// A reusable OTP confirmation step. Used both during signup and whenever an
/// account-sensitive field (phone number, password) is changed from
/// Settings. There's no real SMS gateway behind this yet — same placeholder
/// status as the rest of the app's OTP flow — so [onConfirmed] fires as soon
/// as 6 digits are entered, it isn't actually validated against anything
/// sent to the phone.
class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.onConfirmed, this.subtitle});

  final VoidCallback onConfirmed;
  final String? subtitle;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsLeft = _resendCountdownSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsLeft = _resendCountdownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _confirm() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code')),
      );
      return;
    }
    widget.onConfirmed();
  }

  String get _countdownLabel {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  const SizedBox(height: 180),
                  const SectionHeading(text: 'OTP', centered: true),
                  const SizedBox(height: 16),
                  Text(
                    widget.subtitle ?? "We'll Send You An SMS For The OTP. Enter The Code Below.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B6B6B), height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45,
                        height: 52,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF2F2F2),
                            hintText: '0',
                            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) => _onDigitChanged(index, value),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  FilledActionButton(label: 'Confirm', onPressed: _confirm),
                  const SizedBox(height: 20),
                  _secondsLeft > 0
                      ? Text.rich(
                          TextSpan(
                            text: 'Resend OTP in ',
                            style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 13),
                            children: [
                              TextSpan(
                                text: '$_countdownLabel.',
                                style: const TextStyle(color: kBrandOrange, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: _startCountdown,
                          child: const Text(
                            'Resend OTP',
                            style: TextStyle(color: kBrandOrange, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
