import 'package:equatable/equatable.dart';

sealed class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => [];
}

class SupportFaqsRequested extends SupportEvent {
  const SupportFaqsRequested();
}

class SupportLegalRequested extends SupportEvent {
  const SupportLegalRequested(this.type);

  final String type;

  @override
  List<Object?> get props => [type];
}

class SupportReportSubmitted extends SupportEvent {
  const SupportReportSubmitted({
    required this.subject,
    required this.description,
  });

  final String subject;
  final String description;

  @override
  List<Object?> get props => [subject, description];
}

class SupportFeedbackCleared extends SupportEvent {
  const SupportFeedbackCleared();
}
