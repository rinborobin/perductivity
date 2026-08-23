import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final bool bordered;
  final BorderRadiusGeometry borderRadius;

  const AppSurface({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = EdgeInsets.zero,
    this.color,
    this.bordered = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.lg)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colorScheme.surface,
        borderRadius: borderRadius,
        border: bordered ? Border.all(color: colorScheme.outlineVariant) : null,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
