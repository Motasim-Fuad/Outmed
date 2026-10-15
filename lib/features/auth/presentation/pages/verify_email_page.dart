import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/features/auth/presentation/widgets/auth_submit_button.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> nodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthFeedbackCleared());
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final node in nodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get code => controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final email = RouteArgs.maybe<String>(context) ?? '';
    final purpose =
        GoRouterState.of(context).uri.queryParameters['purpose'] ?? 'reset';
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          !previous.otpVerified && current.otpVerified,
      listener: (context, state) {
        if (purpose == 'signup') {
          AppNav.go(AppRoutes.profileSelection);
          return;
        }
        AppNav.push(AppRoutes.newPassword);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text('verify_email'.tr)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'verify_email'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${'verify_email_body'.tr}\n$email'),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 46,
                      child: TextField(
                        controller: controllers[index],
                        focusNode: nodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            nodes[index + 1].requestFocus();
                          }
                          setState(() {});
                        },
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                AuthSubmitButton(
                  label: 'verify'.tr,
                  enabled: code.length == 6,
                  onPressed: () => context.read<AuthBloc>().add(
                    AuthVerifyOtpRequested(email: email, code: code),
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<AuthBloc>().add(
                    AuthResendOtpRequested(email),
                  ),
                  child: Text('send_code'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
