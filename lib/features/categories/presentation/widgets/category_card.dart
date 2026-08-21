import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/app_surface.dart';
import '../../domain/entities/category_entity.dart';
import 'category_icon.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CategoryCard({
    required this.category,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hexColor = category.color.replaceFirst('#', '');
    final color = Color(
      int.parse(hexColor.length == 6 ? 'FF$hexColor' : hexColor, radix: 16),
    );

    return AppSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(categoryIconFromString(category.icon), color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Edit category',
            icon: const Icon(Icons.edit_outlined),
            onPressed: onTap,
          ),
          IconButton(
            tooltip: 'Delete category',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
