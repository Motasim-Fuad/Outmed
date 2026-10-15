import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_state.dart';
import 'package:outmed/features/catalog/presentation/category_icon.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  final String selectedId;
  final ValueChanged<CategoryOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CategoryBloc, CategoryState, CategoryState>(
      selector: (state) => state,
      builder: (context, state) {
        if (state.loading) return const ShimmerBox(height: 56, radius: 13);
        final categories = state.categories;
        final selected = categories.any((item) => item.id == selectedId)
            ? selectedId
            : null;
        return DropdownButtonFormField<String>(
          key: ValueKey(categories.length),
          initialValue: selected,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: Text('select_category'.tr),
          decoration: InputDecoration(
            labelText: 'category'.tr,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: categories.isEmpty
                ? IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => context.read<CategoryBloc>().add(
                      const CategoryStarted(),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          items: [
            for (final category in categories)
              DropdownMenuItem(
                value: category.id,
                child: Row(
                  children: [
                    Icon(category.icon, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        category.isRoot
                            ? category.name
                            : '${state.byId(category.parentId)?.name ?? ''}'
                                  ' / ${category.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          validator: (value) => value == null
              ? (categories.isEmpty ? 'no_categories'.tr : 'required_field'.tr)
              : null,
          onChanged: categories.isEmpty
              ? null
              : (id) {
                  for (final category in categories) {
                    if (category.id == id) onChanged(category);
                  }
                },
        );
      },
    );
  }
}
