import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final controllers = List.generate(14, (_) => TextEditingController());
  int step = 0;

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          step == 0 ? 'organization_information'.tr : 'business_address'.tr,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _StepBar(current: step),
            const SizedBox(height: 18),
            if (step == 0) ...[
              AppTextField(
                controller: controllers[0],
                label: 'company_name'.tr,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controllers[1],
                label: 'company_type'.tr,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controllers[2],
                label: 'commercial_registration'.tr,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: controllers[3], label: 'vat_number'.tr),
              const SizedBox(height: 12),
              AppTextField(controller: controllers[4], label: 'bank_name'.tr),
              const SizedBox(height: 12),
              AppTextField(
                controller: controllers[5],
                label: 'bank_account_holder'.tr,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: controllers[6], label: 'iban'.tr),
              const SizedBox(height: 12),
              AppTextField(
                controller: controllers[7],
                label: 'year_established'.tr,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controllers[8],
                label: 'number_employees'.tr,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controllers[9],
                label: 'company_website'.tr,
              ),
            ] else ...[
              AppTextField(controller: controllers[10], label: 'country'.tr),
              const SizedBox(height: 12),
              AppTextField(controller: controllers[11], label: 'city'.tr),
              const SizedBox(height: 12),
              AppTextField(controller: controllers[12], label: 'region'.tr),
              const SizedBox(height: 12),
              AppTextField(
                controller: controllers[13],
                label: 'full_address'.tr,
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                if (step > 0) ...[
                  Expanded(
                    child: CustomButton(
                      label: 'back'.tr,
                      outlined: true,
                      onPressed: () => setState(() => step = 0),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: CustomButton(
                    label: step == 0 ? 'next'.tr : 'submit_registration'.tr,
                    onPressed: () {
                      if (step == 0) {
                        setState(() => step = 1);
                        return;
                      }
                      Get.offAllNamed(AppRoutes.login);
                      Get.snackbar('app_name'.tr, 'registration_submitted'.tr);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dot(active: true, label: '1'),
        Expanded(
          child: Container(
            height: 3,
            color: current > 0 ? AppColors.primary : AppColors.border,
          ),
        ),
        _Dot(active: current > 0, label: '2'),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: active ? AppColors.primary : AppColors.border,
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppColors.muted,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
