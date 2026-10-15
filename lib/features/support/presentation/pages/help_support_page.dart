import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/support/data/models/faq_item.dart';
import 'package:outmed/features/support/presentation/bloc/support_bloc.dart';
import 'package:outmed/features/support/presentation/bloc/support_event.dart';
import 'package:outmed/features/support/presentation/bloc/support_state.dart';
import 'package:outmed/features/support/presentation/pages/widgets/faq_shimmer.dart';
import 'package:outmed/features/support/presentation/pages/widgets/faq_tile.dart';
import 'package:outmed/features/support/presentation/pages/widgets/report_problem_form.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  @override
  void initState() {
    super.initState();
    context.read<SupportBloc>()
      ..add(const SupportFeedbackCleared())
      ..add(const SupportFaqsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('help_support'.tr)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Text(
            'faq_title'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          BlocSelector<SupportBloc, SupportState, (LoadStatus, List<FaqItem>)>(
            selector: (state) => (state.faqStatus, state.faqs),
            builder: (context, data) {
              final (status, faqs) = data;
              if (status == LoadStatus.loading && faqs.isEmpty) {
                return const FaqShimmer();
              }
              return Column(
                children: [for (final faq in faqs) FaqTile(faq: faq)],
              );
            },
          ),
          const SizedBox(height: 22),
          Text(
            'report_problem'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const ReportProblemForm(),
          const SizedBox(height: 22),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.primary,
            ),
            title: Text('privacy_policy'.tr),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => AppNav.push('${AppRoutes.legal}?type=PRIVACY_POLICY'),
          ),
        ],
      ),
    );
  }
}
