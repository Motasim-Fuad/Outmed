import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/support/data/models/faq_item.dart';

class SupportState extends Equatable {
  const SupportState({
    this.faqs = const [],
    this.faqStatus = LoadStatus.initial,
    this.legal = const {},
    this.legalStatus = LoadStatus.initial,
    this.legalError = '',
    this.reportStatus = LoadStatus.initial,
    this.reportSent = false,
    this.errorMessage = '',
  });

  final List<FaqItem> faqs;
  final LoadStatus faqStatus;
  final Map<String, String> legal;
  final LoadStatus legalStatus;
  final String legalError;
  final LoadStatus reportStatus;
  final bool reportSent;
  final String errorMessage;

  SupportState copyWith({
    List<FaqItem>? faqs,
    LoadStatus? faqStatus,
    Map<String, String>? legal,
    LoadStatus? legalStatus,
    String? legalError,
    LoadStatus? reportStatus,
    bool? reportSent,
    String? errorMessage,
  }) {
    return SupportState(
      faqs: faqs ?? this.faqs,
      faqStatus: faqStatus ?? this.faqStatus,
      legal: legal ?? this.legal,
      legalStatus: legalStatus ?? this.legalStatus,
      legalError: legalError ?? this.legalError,
      reportStatus: reportStatus ?? this.reportStatus,
      reportSent: reportSent ?? this.reportSent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    faqs,
    faqStatus,
    legal,
    legalStatus,
    legalError,
    reportStatus,
    reportSent,
    errorMessage,
  ];
}
