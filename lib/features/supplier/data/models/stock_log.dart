import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class StockLog extends Equatable {
  const StockLog({
    required this.id,
    required this.adjustment,
    required this.reason,
    this.notes = '',
    this.previousStock,
    this.newStock,
    this.createdAt,
  });

  final String id;
  final int adjustment;
  final String reason;
  final String notes;
  final int? previousStock;
  final int? newStock;
  final DateTime? createdAt;

  static StockLog? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id']);
    if (id == null) return null;
    final previous = ApiJson.integer(json, const [
      'previousQuantity',
      'previousStock',
      'oldQuantity',
      'quantityBefore',
    ]);
    final next = ApiJson.integer(json, const [
      'newQuantity',
      'newStock',
      'quantityAfter',
      'currentQuantity',
    ]);
    final adjustment =
        ApiJson.integer(json, const [
          'adjustment',
          'quantityChange',
          'change',
          'quantity',
        ]) ??
        (previous != null && next != null ? next - previous : 0);
    final created = ApiJson.text(json, const ['createdAt', 'created_at']);
    return StockLog(
      id: id,
      adjustment: adjustment,
      reason: ApiJson.text(json, const ['reason', 'type']) ?? '',
      notes: ApiJson.text(json, const ['notes', 'note']) ?? '',
      previousStock: previous,
      newStock: next,
      createdAt: created == null ? null : DateTime.tryParse(created)?.toLocal(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    adjustment,
    reason,
    notes,
    previousStock,
    newStock,
    createdAt,
  ];
}
