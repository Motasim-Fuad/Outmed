import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/outmed_logo.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final pageController = PageController();
  int currentPage = 0;

  static const pages = [
    (
      image: AppAssets.catalogIllustration,
      title: 'onboarding_title_1',
      body: 'onboarding_body_1',
    ),
    (
      image: AppAssets.orderIllustration,
      title: 'onboarding_title_2',
      body: 'onboarding_body_2',
    ),
    (
      image: AppAssets.deliveryIllustration,
      title: 'onboarding_title_3',
      body: 'onboarding_body_3',
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastPage = currentPage == pages.length - 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          child: Column(
            children: [
              Row(
                children: [
                  const OutMedLogo(height: 40),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.authLanding),
                    child: Text('skip'.tr),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => currentPage = value),
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Column(
                      children: [
                        const Spacer(),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 330),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: AppAssetImage(page.image),
                        ),
                        const Spacer(),
                        Text(
                          page.title.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 27,
                            height: 1.18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: currentPage == index ? 24 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: lastPage ? 'get_started'.tr : 'continue'.tr,
                onPressed: () {
                  if (lastPage) {
                    Get.offAllNamed(AppRoutes.authLanding);
                    return;
                  }
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
