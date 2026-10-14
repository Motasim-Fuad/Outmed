import 'package:equatable/equatable.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class CatalogStarted extends CatalogEvent {
  const CatalogStarted();
}

class CatalogSearchChanged extends CatalogEvent {
  const CatalogSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class CatalogRefreshRequested extends CatalogEvent {
  const CatalogRefreshRequested();
}
