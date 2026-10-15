import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_state.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class MedicalCategoryPicker extends StatelessWidget {
  const MedicalCategoryPicker({
    required this.selected,
    required this.onChanged,
    this.error = '',
    super.key,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final String error;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CategoryBloc, CategoryState, CategoryState>(
      selector: (state) => state,
      builder: (context, state) {
        if (state.loading) return const ShimmerBox(height: 40);
        if (state.categories.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'medical_categories'.tr,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in state.categories)
                  FilterChip(
                    label: Text(category.name),
                    selected: selected.contains(category.id),
                    selectedColor: AppColors.primary.withValues(alpha: .14),
                    checkmarkColor: AppColors.primary,
                    onSelected: (value) => onChanged(
                      value
                          ? {...selected, category.id}
                          : ({...selected}..remove(category.id)),
                    ),
                  ),
              ],
            ),
            InlineErrorText(message: error),
          ],
        );
      },
    );
  }
}
