import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/category_entity.dart';
import 'category_icon.dart';

class CategoryDialog extends StatefulWidget {
  final CategoryEntity? category;
  final void Function(String name, String color, String icon) onSave;

  const CategoryDialog({required this.onSave, this.category, super.key});

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _selectedColor = AppColors.primary
      .toARGB32()
      .toRadixString(16)
      .padLeft(8, '0')
      .substring(2);
  String _selectedIcon = '58281';

  final List<String> _colors = [
    '2563EB',
    '38BDF8',
    '22C55E',
    'F59E0B',
    'EF4444',
    '06B6D4',
    '8B5CF6',
    'EC4899',
  ];

  final List<int> _icons = [
    0xe3a9,
    0xe866,
    0xe896,
    0xe0b0,
    0xe559,
    0xe8b8,
    0xe8f1,
    0xe87c,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    if (widget.category != null) {
      _selectedColor = widget.category!.color.replaceFirst('#', '');
      _selectedIcon = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.category == null ? 'Create Category' : 'Edit Category',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Color(
                  int.parse('0xFF$_selectedColor'),
                ).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: Color(
                    int.parse('0xFF$_selectedColor'),
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(int.parse('0xFF$_selectedColor')),
                    child: Icon(
                      categoryIconFromString(_selectedIcon),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _nameController.text.isEmpty
                          ? 'Preview category'
                          : _nameController.text,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Color'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF$color')),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Icon'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _icons.map((icon) {
                final isSelected = _selectedIcon == icon.toString();
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon.toString()),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Icon(
                      categoryIconFromString(icon.toString()),
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _nameController.text,
                _selectedColor,
                _selectedIcon,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
