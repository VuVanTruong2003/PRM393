import 'package:flutter/material.dart';

import '../../core/app_ui.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Theme.of(context).cardColor;
    return DecoratedBox(
      decoration: AppUI.cardDecoration(color: bg),
      child: Padding(padding: padding, child: child),
    );
  }
}

