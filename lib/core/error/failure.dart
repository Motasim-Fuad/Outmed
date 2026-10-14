import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isNetworkError => statusCode == null || statusCode == 0;

  @override
  List<Object?> get props => [message, statusCode];
}
