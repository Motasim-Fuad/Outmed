import 'package:equatable/equatable.dart';

sealed class StockLogEvent extends Equatable {
  const StockLogEvent();

  @override
  List<Object?> get props => [];
}

class StockLogsRequested extends StockLogEvent {
  const StockLogsRequested(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
