import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_state.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    required this.controller,
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String selectedId;
  final ValueChanged<CategoryOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SupplierBloc, SupplierState, List<CategoryOption>>(
      selector: (state) => state.categories,
      builder: (context, categories) {
        if (categories.isEmpty) {
          return AppTextField(
            controller: controller,
            label: 'category'.tr,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'required_field'.tr
                : null,
          );
        }
        final selected = categories.any((item) => item.id == selectedId)
            ? selectedId
            : null;
        return DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'category'.tr,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          items: [
            for (final category in categories)
              DropdownMenuItem(value: category.id, child: Text(category.name)),
          ],
          validator: (value) => value == null ? 'required_field'.tr : null,
          onChanged: (id) {
            for (final category in categories) {
              if (category.id == id) onChanged(category);
            }
          },
        );
      },
    );
  }
}
