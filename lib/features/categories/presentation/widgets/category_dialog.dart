import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/category_entity.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
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
      .substring(2)
      .toUpperCase();
  String _selectedIcon = '58281';

  final List<String> _colors = [
    '55B58A',
    '7CC9A3',
    '8AB9A6',
    'D59A4C',
    'D96B6B',
    '73AEBB',
    '9B8FC5',
    'C8789A',
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
      _selectedColor = widget.category!.color
          .replaceFirst('#', '')
          .toUpperCase();
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
    return AppBottomSheet(
      title: widget.category == null ? 'Create Category' : 'Edit Category',
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
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
                    onTap: () =>
                        setState(() => _selectedIcon = icon.toString()),
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
                              : Theme.of(context).colorScheme.outlineVariant,
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
      ),
      actions: [
        AppActionButton(
          primary: false,
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppActionButton(
          label: 'Save',
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
        ),
      ],
    );
  }
}
