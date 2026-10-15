import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class CategoryOption extends Equatable {
  const CategoryOption({required this.id, required this.name});

  final String id;
  final String name;

  static CategoryOption? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id']);
    final name = ApiJson.text(json, const ['name', 'title']);
    if (id == null || name == null) return null;
    return CategoryOption(id: id, name: name);
  }

  @override
  List<Object?> get props => [id, name];
}
