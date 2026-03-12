import 'package:flutter/material.dart';

class AnimatedAppear extends StatefulWidget {
  const AnimatedAppear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 12,
    this.duration = const Duration(milliseconds: 320),
  });

  final Widget child;
  final Duration delay;
  final double offsetY;
  final Duration duration;

  @override
  State<AnimatedAppear> createState() => _AnimatedAppearState();
}

class _AnimatedAppearState extends State<AnimatedAppear> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      opacity: _visible ? 1 : 0,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: widget.duration,
        curve: Curves.easeOut,
        offset: _visible ? Offset.zero : Offset(0, widget.offsetY / 100),
        child: widget.child,
      ),
    );
  }
}

