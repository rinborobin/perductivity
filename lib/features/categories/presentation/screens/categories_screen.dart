import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/category_list_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/category_dialog.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesState.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Create your first category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Categories help you keep tasks organized.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppActionButton(
                      icon: Icons.add,
                      label: 'Add category',
                      onPressed: () => _showCreateDialog(context, ref),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                category: category,
                onTap: () => _showEditDialog(context, ref, category),
                onDelete: () => _confirmDelete(context, ref, category.id!),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: AppActionButton(
            icon: Icons.refresh,
            label: 'Try again',
            onPressed: () =>
                ref.read(categoryListProvider.notifier).loadCategories(),
          ),
        ),
      ),
      floatingActionButton: AppActionButton(
        label: 'Add category',
        icon: Icons.add,
        onPressed: () => _showCreateDialog(context, ref),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CategoryDialog(
        onSave: (name, color, icon) {
          ref
              .read(categoryListProvider.notifier)
              .createCategory(name: name, color: color, icon: icon);
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity category,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CategoryDialog(
        category: category,
        onSave: (name, color, icon) {
          ref
              .read(categoryListProvider.notifier)
              .updateCategory(
                id: category.id!,
                name: name,
                color: color,
                icon: icon,
              );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => AppBottomSheet(
        title: 'Delete Category',
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          AppActionButton(
            primary: false,
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppActionButton(
            label: 'Delete',
            danger: true,
            onPressed: () {
              ref.read(categoryListProvider.notifier).deleteCategory(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
