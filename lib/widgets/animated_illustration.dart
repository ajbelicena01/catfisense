import 'package:flutter/material.dart';

/// Renders a stack of PNG layers (rasterized from Figma/Canva SVG exports that
/// share one common canvas) and staggers each layer's entrance with a fade +
/// slight upward slide, background layers first.
///
/// Layers are rasterized ahead of time rather than rendered as SVG because
/// some exported layers use a mask+filter combo (a common Figma/Canva trick
/// for simulating opacity) that flutter_svg silently fails to render.
class AnimatedIllustration extends StatefulWidget {
  const AnimatedIllustration({
    super.key,
    required this.assetPaths,
    this.aspectRatio = 594.95996 / 842.24997,
  });

  final List<String> assetPaths;
  final double aspectRatio;

  @override
  State<AnimatedIllustration> createState() => _AnimatedIllustrationState();
}

class _AnimatedIllustrationState extends State<AnimatedIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.assetPaths.length * 120),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.assetPaths.length;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: List.generate(count, (index) {
          final start = count == 1 ? 0.0 : (index / count) * 0.7;
          final end = (start + 0.3).clamp(0.0, 1.0);
          final layerAnimation = CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          );
          return AnimatedBuilder(
            animation: layerAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: layerAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, (1 - layerAnimation.value) * 16),
                  child: child,
                ),
              );
            },
            child: Image.asset(widget.assetPaths[index], fit: BoxFit.fill),
          );
        }),
      ),
    );
  }
}
