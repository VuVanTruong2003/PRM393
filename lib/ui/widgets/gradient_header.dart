import 'package:flutter/material.dart';

import '../../core/app_ui.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.height = 170,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppUI.headerGradient),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

