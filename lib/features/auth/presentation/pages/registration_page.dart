import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/features/auth/presentation/pages/widgets/medical_category_picker.dart';
import 'package:outmed/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_bloc.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final List<TextEditingController> controllers = List.generate(
    14,
    (_) => TextEditingController(),
  );
  final formKey = GlobalKey<FormState>();
  int step = 0;
  String companyType = 'Manufacturer';
  Set<String> medicalCategories = {};
  String categoryError = '';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supplier = context.read<AuthBloc>().state.role == UserRole.supplier;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          !previous.accountCreated && current.accountCreated,
      listener: (context, state) {
        AppNav.go(
          state.authenticated
              ? (state.role == UserRole.supplier
                    ? AppRoutes.supplierMain
                    : AppRoutes.buyerMain)
              : AppRoutes.login,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            step == 0 ? 'organization_information'.tr : 'business_address'.tr,
          ),
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _StepBar(current: step),
                const SizedBox(height: 18),
                if (step == 0) ...[
                  AppTextField(
                    controller: controllers[0],
                    label: 'company_name'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  if (supplier) ...[
                    DropdownButtonFormField<String>(
                      initialValue: companyType,
                      decoration: InputDecoration(labelText: 'company_type'.tr),
                      items: [
                        for (final type in _companyTypes)
                          DropdownMenuItem(value: type, child: Text(type)),
                      ],
                      onChanged: (value) =>
                          setState(() => companyType = value ?? companyType),
                    ),
                    const SizedBox(height: 12),
                  ],
                  AppTextField(
                    controller: controllers[2],
                    label: 'commercial_registration'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controllers[3],
                    label: 'vat_number'.tr,
                    hint: supplier ? null : 'optional'.tr,
                    validator: supplier ? Validators.required : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controllers[4],
                    label: 'bank_name'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controllers[5],
                    label: 'bank_account_holder'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controllers[6],
                    label: 'iban'.tr,
                    validator: Validators.required,
                  ),
                  if (supplier) ...[
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: controllers[7],
                      label: 'year_established'.tr,
                      keyboardType: TextInputType.number,
                      validator: Validators.year,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: controllers[8],
                      label: 'number_employees'.tr,
                      hint: 'optional'.tr,
                    ),
                  ],
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controllers[9],
                    label: 'company_website'.tr,
                    hint: 'optional'.tr,
                    keyboardType: TextInputType.url,
                    validator: Validators.optionalWebsite,
                  ),
                ] else ...[
                  AppTextField(
                    controller: controllers[10],
                    label: 'country'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controllers[11],
                    label: 'city'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controllers[12],
                    label: 'postal_code'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controllers[13],
                    label: 'full_address'.tr,
                    maxLines: 3,
                    validator: Validators.required,
                  ),
                  if (supplier) ...[
                    const SizedBox(height: 16),
                    MedicalCategoryPicker(
                      selected: medicalCategories,
                      error: categoryError,
                      onChanged: (value) => setState(() {
                        medicalCategories = value;
                        categoryError = '';
                      }),
                    ),
                  ],
                ],
                const SizedBox(height: 22),
                if (step > 0) ...[
                  CustomButton(
                    label: 'back'.tr,
                    outlined: true,
                    onPressed: () => setState(() => step = 0),
                  ),
                  const SizedBox(height: 10),
                ],
                AuthSubmitButton(
                  label: step == 0 ? 'next'.tr : 'submit_registration'.tr,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _continue() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (step == 0) {
      setState(() => step = 1);
      return;
    }
    final auth = context.read<AuthBloc>();
    final hasCategories = context
        .read<CategoryBloc>()
        .state
        .categories
        .isNotEmpty;
    if (auth.state.role == UserRole.supplier &&
        hasCategories &&
        medicalCategories.isEmpty) {
      setState(() => categoryError = 'select_medical_category'.tr);
      return;
    }
    auth.add(
      AuthRegisterRequested({
        'company_name': controllers[0].text.trim(),
        'company_type': companyType,
        'commercial_registration': controllers[2].text.trim(),
        'vat_number': controllers[3].text.trim(),
        'bank_name': controllers[4].text.trim(),
        'bank_account_holder': controllers[5].text.trim(),
        'iban': controllers[6].text.trim(),
        'year_established': controllers[7].text.trim(),
        'number_of_employees': controllers[8].text.trim(),
        'website': controllers[9].text.trim(),
        'country': controllers[10].text.trim(),
        'city': controllers[11].text.trim(),
        'postal_code': controllers[12].text.trim(),
        'address': controllers[13].text.trim(),
        'role': auth.state.role.name,
        'medical_categories': medicalCategories.join(','),
      }),
    );
  }
}

const _companyTypes = ['Manufacturer', 'Distributor', 'Wholesaler'];

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _Dot(active: true, label: '1'),
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
