import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/profile/presentation/pages/profile_page.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_state.dart';
import 'package:outmed/features/supplier/presentation/pages/supplier_inventory_page.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/supplier_home.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/supplier_orders_tab.dart';
import 'package:outmed/shared/widgets/custom_bottom_nav.dart';

class SupplierMainPage extends StatelessWidget {
  const SupplierMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SupplierBloc, SupplierState, int>(
      selector: (state) => state.shellIndex,
      builder: (context, currentIndex) => Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: const [
            SupplierHome(),
            SupplierOrdersTab(),
            SizedBox.shrink(),
            SupplierInventoryPage(embedded: true),
            ProfilePage(supplier: true),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              AppNav.push(AppRoutes.addOffer);
              return;
            }
            context.read<SupplierBloc>().add(SupplierShellSelected(index));
          },
          destinations: [
            NavDestination(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'dashboard'.tr,
            ),
            NavDestination(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long,
              label: 'orders'.tr,
            ),
            NavDestination(
              icon: Icons.add_rounded,
              activeIcon: Icons.add_rounded,
              label: 'catalog'.tr,
              isCenter: true,
            ),
            NavDestination(
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2_rounded,
              label: 'inventory'.tr,
            ),
            NavDestination(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'profile'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
