import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class CategoryOption extends Equatable {
  const CategoryOption({
    required this.id,
    required this.name,
    this.slug = '',
    this.imageUrl = '',
    this.parentId = '',
    this.productCount,
  });

  final String id;
  final String name;
  final String slug;
  final String imageUrl;
  final String parentId;
  final int? productCount;

  bool get isRoot => parentId.isEmpty;

  static CategoryOption? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id']);
    final name = ApiJson.text(json, const ['name', 'title']);
    if (id == null || name == null) return null;
    final count = ApiJson.asMap(json['_count']);
    return CategoryOption(
      id: id,
      name: name,
      slug: ApiJson.text(json, const ['slug']) ?? '',
      imageUrl: ApiJson.text(json, const ['imageUrl', 'image_url']) ?? '',
      parentId: ApiJson.text(json, const ['parentId', 'parent_id']) ?? '',
      productCount: count == null
          ? ApiJson.integer(json, const ['productCount', 'productsCount'])
          : ApiJson.integer(count, const ['products']),
    );
  }

  static List<CategoryOption> parseList(Object? body) {
    final result = <CategoryOption>[];
    void visit(Map<String, Object?> json, {String parentId = ''}) {
      final parsed = tryParse(json);
      if (parsed == null) return;
      final category = parsed.parentId.isEmpty && parentId.isNotEmpty
          ? CategoryOption(
              id: parsed.id,
              name: parsed.name,
              slug: parsed.slug,
              imageUrl: parsed.imageUrl,
              parentId: parentId,
              productCount: parsed.productCount,
            )
          : parsed;
      if (result.every((item) => item.id != category.id)) result.add(category);
      final children = json['children'];
      if (children is List) {
        for (final child in children) {
          final map = ApiJson.asMap(child);
          if (map != null) visit(map, parentId: category.id);
        }
      }
    }

    ApiJson.maps(body).forEach(visit);
    return result;
  }

  @override
  List<Object?> get props => [id, name, slug, imageUrl, parentId, productCount];
}
