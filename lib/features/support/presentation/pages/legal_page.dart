import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/support/presentation/bloc/support_bloc.dart';
import 'package:outmed/features/support/presentation/bloc/support_event.dart';
import 'package:outmed/features/support/presentation/bloc/support_state.dart';
import 'package:outmed/features/support/presentation/pages/widgets/legal_shimmer.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class LegalPage extends StatefulWidget {
  const LegalPage({required this.type, super.key});

  final String type;

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  @override
  void initState() {
    super.initState();
    context.read<SupportBloc>().add(SupportLegalRequested(widget.type));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'PRIVACY_POLICY'
        ? 'privacy_policy'.tr
        : 'terms_conditions'.tr;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text(title)),
      body:
          BlocSelector<SupportBloc, SupportState, (LoadStatus, String, String)>(
            selector: (state) => (
              state.legalStatus,
              state.legal[widget.type] ?? '',
              state.legalError,
            ),
            builder: (context, data) {
              final (status, content, error) = data;
              if (status == LoadStatus.loading && content.isEmpty) {
                return const LegalShimmer();
              }
              return RefreshIndicator(
                onRefresh: () async => context.read<SupportBloc>().add(
                  SupportLegalRequested(widget.type),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                  children: [
                    if (content.isNotEmpty)
                      Text(content, style: const TextStyle(height: 1.55))
                    else
                      InlineErrorText(
                        message: error.isEmpty ? 'legal_unavailable'.tr : error,
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
