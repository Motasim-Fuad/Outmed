import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/profile/data/models/user_profile.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_event.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_state.dart';
import 'package:outmed/features/profile/presentation/pages/widgets/profile_save_button.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/form_shimmer.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({this.addressOnly = false, super.key});

  final bool addressOnly;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();
  final organization = TextEditingController();
  final bankName = TextEditingController();
  final holder = TextEditingController();
  final iban = TextEditingController();
  final country = TextEditingController();
  final city = TextEditingController();
  final address = TextEditingController();
  final postalCode = TextEditingController();
  final pickup = TextEditingController();
  final website = TextEditingController();
  final year = TextEditingController();
  final employees = TextEditingController();
  late final bool supplier;
  UserProfile _filledFrom = UserProfile.empty;

  List<TextEditingController> get _all => [
    organization,
    bankName,
    holder,
    iban,
    country,
    city,
    address,
    postalCode,
    pickup,
    website,
    year,
    employees,
  ];

  @override
  void initState() {
    super.initState();
    supplier = context.read<AuthBloc>().state.role == UserRole.supplier;
    final profile = context.read<ProfileBloc>()
      ..add(const ProfileFeedbackCleared());
    if (profile.state.profile.isEmpty) profile.add(const ProfileStarted());
    _fill(profile.state.profile);
  }

  @override
  void dispose() {
    for (final controller in _all) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fill(UserProfile profile) {
    if (profile.isEmpty || profile == _filledFrom) return;
    _filledFrom = profile;
    organization.text = profile.organization;
    bankName.text = profile.bankName;
    holder.text = profile.bankAccountHolderName;
    iban.text = profile.iban;
    country.text = profile.country;
    city.text = profile.city;
    address.text = profile.fullAddress;
    postalCode.text = profile.postalCode;
    pickup.text = profile.pickupAddress;
    website.text = profile.website;
    year.text = profile.yearsEstablished;
    employees.text = profile.numberOfEmployees;
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final site = website.text.trim();
    context.read<ProfileBloc>().add(
      ProfileUpdateRequested({
        if (!widget.addressOnly) ...{
          supplier ? 'companyName' : 'organizationName': organization.text,
          'bankName': bankName.text,
          'bankAccountHolderName': holder.text,
          'iban': iban.text,
        },
        'country': country.text,
        'city': city.text,
        'fullAddress': address.text,
        'postalCode': postalCode.text,
        if (supplier) 'pickupAddress': pickup.text,
        if (supplier && !widget.addressOnly) ...{
          'yearsEstablished': int.tryParse(year.text.trim()),
          'numberOfEmployees': employees.text,
          'companyWebsite': site.isEmpty || site.contains('://')
              ? site
              : 'https://$site',
        },
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.profile != current.profile ||
          (!previous.saved && current.saved),
      listener: (context, state) {
        if (state.saved) {
          AppNav.pop();
          return;
        }
        setState(() => _fill(state.profile));
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: Text(
            widget.addressOnly ? 'addresses'.tr : 'edit_profile'.tr,
          ),
        ),
        body: BlocSelector<ProfileBloc, ProfileState, bool>(
          selector: (state) =>
              state.status == LoadStatus.loading && state.profile.isEmpty,
          builder: (context, loading) {
            if (loading) return const FormShimmer(fields: 9);
            return Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                children: [
                  if (!widget.addressOnly) ...[
                    AppTextField(
                      controller: organization,
                      label: supplier
                          ? 'company_name'.tr
                          : 'organization_name'.tr,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: bankName,
                      label: 'bank_name'.tr,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: holder,
                      label: 'bank_account_holder'.tr,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: iban,
                      label: 'iban'.tr,
                      validator: Validators.required,
                    ),
                    if (supplier) ...[
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: year,
                        label: 'year_established'.tr,
                        keyboardType: TextInputType.number,
                        validator: Validators.year,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: employees,
                        label: '${'number_of_employees'.tr} (${'optional'.tr})',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: website,
                        label: '${'company_website'.tr} (${'optional'.tr})',
                        keyboardType: TextInputType.url,
                        validator: Validators.optionalWebsite,
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                  AppTextField(
                    controller: country,
                    label: 'country'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: city,
                    label: 'city'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: postalCode,
                    label: 'postal_code'.tr,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: address,
                    label: 'full_address'.tr,
                    maxLines: 2,
                    validator: Validators.required,
                  ),
                  if (supplier) ...[
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: pickup,
                      label: 'pickup_address'.tr,
                      maxLines: 2,
                      validator: Validators.required,
                    ),
                  ],
                  const SizedBox(height: 22),
                  ProfileSaveButton(label: 'save_changes'.tr, onPressed: _save),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
