import 'package:equatable/equatable.dart';

sealed class SupplierDirectoryEvent extends Equatable {
  const SupplierDirectoryEvent();

  @override
  List<Object?> get props => [];
}

class SupplierDirectoryStarted extends SupplierDirectoryEvent {
  const SupplierDirectoryStarted();
}

class SupplierDirectorySearchChanged extends SupplierDirectoryEvent {
  const SupplierDirectorySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class SupplierDirectoryDetailRequested extends SupplierDirectoryEvent {
  const SupplierDirectoryDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
