import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/supplier/data/models/stock_log.dart';

class StockLogState extends Equatable {
  const StockLogState({
    this.logs = const [],
    this.status = LoadStatus.initial,
    this.errorMessage = '',
  });

  final List<StockLog> logs;
  final LoadStatus status;
  final String errorMessage;

  bool get loading => status == LoadStatus.loading && logs.isEmpty;

  StockLogState copyWith({
    List<StockLog>? logs,
    LoadStatus? status,
    String? errorMessage,
  }) {
    return StockLogState(
      logs: logs ?? this.logs,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [logs, status, errorMessage];
}
