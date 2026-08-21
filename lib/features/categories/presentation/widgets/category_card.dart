import 'package:flutter/material.dart';
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

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(categoryIconFromString(category.icon), color: color),
        ),
        title: Text(category.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onTap),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
