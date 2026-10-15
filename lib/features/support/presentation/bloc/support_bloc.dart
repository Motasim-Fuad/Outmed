import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/offline_queue.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/support/data/models/faq_item.dart';
import 'package:outmed/features/support/presentation/bloc/support_event.dart';
import 'package:outmed/features/support/presentation/bloc/support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc(this._cache, this._queue) : super(const SupportState()) {
    on<SupportFaqsRequested>(_onFaqs);
    on<SupportLegalRequested>(_onLegal);
    on<SupportReportSubmitted>(_onReport);
    on<SupportFeedbackCleared>(
      (event, emit) => emit(
        state.copyWith(
          reportSent: false,
          reportStatus: LoadStatus.initial,
          errorMessage: '',
        ),
      ),
    );
  }

  final RemoteCache _cache;
  final OfflineQueue _queue;

  Future<void> _onFaqs(
    SupportFaqsRequested event,
    Emitter<SupportState> emit,
  ) async {
    if (!AppEnv.useRemote) {
      emit(state.copyWith(faqs: _fallbackFaqs, faqStatus: LoadStatus.success));
      return;
    }
    final cached = _parse(_cache.peek(ApiEndpoints.faqs));
    emit(
      state.copyWith(
        faqs: cached.isEmpty ? null : cached,
        faqStatus: cached.isEmpty ? LoadStatus.loading : LoadStatus.success,
      ),
    );
    try {
      final faqs = _parse(await _cache.get(ApiEndpoints.faqs));
      emit(
        state.copyWith(
          faqs: faqs.isEmpty ? _fallbackFaqs : faqs,
          faqStatus: LoadStatus.success,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          faqs: state.faqs.isEmpty ? _fallbackFaqs : null,
          faqStatus: LoadStatus.failure,
          errorMessage: ApiError.message(error),
        ),
      );
    }
  }

  Future<void> _onLegal(
    SupportLegalRequested event,
    Emitter<SupportState> emit,
  ) async {
    final path = ApiEndpoints.legal(event.type);
    final cached = _content(_cache.peek(path));
    emit(
      state.copyWith(
        legal: cached.isEmpty ? null : {...state.legal, event.type: cached},
        legalStatus: cached.isEmpty ? LoadStatus.loading : LoadStatus.success,
        legalError: '',
      ),
    );
    if (!AppEnv.useRemote) {
      emit(state.copyWith(legalStatus: LoadStatus.success));
      return;
    }
    try {
      final content = _content(await _cache.get(path));
      emit(
        state.copyWith(
          legal: {...state.legal, event.type: content},
          legalStatus: LoadStatus.success,
        ),
      );
    } on DioException catch (error) {
      emit(
        state.copyWith(
          legalStatus: LoadStatus.failure,
          legalError: error.response?.statusCode == 404
              ? AppLocale.translate('legal_unavailable')
              : ApiError.message(error),
        ),
      );
    }
  }

  Future<void> _onReport(
    SupportReportSubmitted event,
    Emitter<SupportState> emit,
  ) async {
    emit(
      state.copyWith(
        reportStatus: LoadStatus.loading,
        reportSent: false,
        errorMessage: '',
      ),
    );
    try {
      await _queue.send(
        'POST',
        ApiEndpoints.reportProblem,
        body: {
          'subject': event.subject.trim(),
          'description': event.description.trim(),
        },
      );
      emit(state.copyWith(reportStatus: LoadStatus.success, reportSent: true));
    } on Object catch (error) {
      emit(
        state.copyWith(
          reportStatus: LoadStatus.failure,
          errorMessage: ApiError.message(error),
        ),
      );
    }
  }

  List<FaqItem> _parse(Object? body) {
    return ApiJson.maps(
      body,
    ).map(FaqItem.tryParse).whereType<FaqItem>().toList(growable: false);
  }

  String _content(Object? body) {
    final json = ApiJson.asMap(ApiJson.unwrap(body));
    if (json == null) return '';
    return ApiJson.text(json, const ['content', 'body', 'text']) ?? '';
  }

  List<FaqItem> get _fallbackFaqs => [
    for (var index = 1; index <= 4; index++)
      FaqItem(
        question: AppLocale.translate('faq_q$index'),
        answer: AppLocale.translate('faq_a$index'),
      ),
  ];
}
