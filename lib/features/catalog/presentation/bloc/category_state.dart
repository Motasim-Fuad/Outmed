import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';

class CategoryState extends Equatable {
  const CategoryState({
    this.categories = const [],
    this.status = LoadStatus.initial,
    this.errorMessage = '',
  });

  final List<CategoryOption> categories;
  final LoadStatus status;
  final String errorMessage;

  bool get loading => status == LoadStatus.loading && categories.isEmpty;

  List<CategoryOption> get roots {
    final roots = categories.where((item) => item.isRoot).toList();
    return roots.isEmpty ? categories : roots;
  }

  CategoryOption? byId(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  CategoryState copyWith({
    List<CategoryOption>? categories,
    LoadStatus? status,
    String? errorMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [categories, status, errorMessage];
}
