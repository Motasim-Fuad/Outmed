import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/support/presentation/bloc/support_bloc.dart';
import 'package:outmed/features/support/presentation/bloc/support_event.dart';
import 'package:outmed/features/support/presentation/bloc/support_state.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class ReportProblemForm extends StatefulWidget {
  const ReportProblemForm({super.key});

  @override
  State<ReportProblemForm> createState() => _ReportProblemFormState();
}

class _ReportProblemFormState extends State<ReportProblemForm> {
  final formKey = GlobalKey<FormState>();
  final subject = TextEditingController();
  final description = TextEditingController();

  @override
  void dispose() {
    subject.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupportBloc, SupportState>(
      listenWhen: (previous, current) =>
          !previous.reportSent && current.reportSent,
      listener: (context, state) {
        subject.clear();
        description.clear();
      },
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: subject,
              label: 'subject'.tr,
              validator: Validators.required,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: description,
              label: 'description'.tr,
              maxLines: 4,
              validator: Validators.required,
            ),
            const SizedBox(height: 14),
            BlocSelector<SupportBloc, SupportState, (bool, bool, String)>(
              selector: (state) => (
                state.reportStatus == LoadStatus.loading,
                state.reportSent,
                state.errorMessage,
              ),
              builder: (context, data) {
                final (loading, sent, error) = data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: 'submit'.tr,
                      isLoading: loading,
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        context.read<SupportBloc>().add(
                          SupportReportSubmitted(
                            subject: subject.text,
                            description: description.text,
                          ),
                        );
                      },
                    ),
                    if (sent)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'report_received'.tr,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    InlineErrorText(message: error),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
