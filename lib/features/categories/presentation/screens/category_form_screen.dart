import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/category_colors.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import '../widgets/color_picker_grid.dart';
import '../widgets/icon_picker_grid.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({this.category, super.key});

  final Category? category;

  @override
  ConsumerState<CategoryFormScreen> createState() =>
      _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _colorValue;
  late String _iconKey;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _colorValue = category?.colorValue ?? CategoryColors.defaultColor.toARGB32();
    _iconKey = category?.iconKey ?? CategoryIcons.defaultKey;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();

    if (_isEditing) {
      final updated = widget.category!.copyWith(
        name: name,
        colorValue: _colorValue,
        iconKey: _iconKey,
      );
      await ref.read(updateCategoryUseCaseProvider).call(updated);
    } else {
      await ref.read(createCategoryUseCaseProvider).call(
            name: name,
            colorValue: _colorValue,
            iconKey: _iconKey,
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCategory : l10n.addCategory),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.categoryName),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(l10n.categoryColor, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ColorPickerGrid(
              selectedColorValue: _colorValue,
              onChanged: (value) => setState(() => _colorValue = value),
            ),
            const SizedBox(height: 24),
            Text(l10n.categoryIcon, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            IconPickerGrid(
              selectedKey: _iconKey,
              accentColor: Color(_colorValue),
              onChanged: (value) => setState(() => _iconKey = value),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
