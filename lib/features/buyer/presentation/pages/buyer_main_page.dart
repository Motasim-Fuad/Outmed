import 'package:flutter/material.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/buyer_categories_tab.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/buyer_home.dart';
import 'package:outmed/features/cart/presentation/pages/cart_page.dart';
import 'package:outmed/features/messages/presentation/pages/messages_page.dart';
import 'package:outmed/features/profile/presentation/pages/profile_page.dart';
import 'package:outmed/shared/widgets/custom_bottom_nav.dart';

class BuyerMainPage extends StatefulWidget {
  const BuyerMainPage({super.key});

  @override
  State<BuyerMainPage> createState() => _BuyerMainPageState();
}

class _BuyerMainPageState extends State<BuyerMainPage> {
  int currentIndex = 0;

  static const List<Widget> _pages = [
    BuyerHome(),
    BuyerCategoriesTab(),
    CartPage(),
    MessagesPage(),
    ProfilePage(supplier: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: [
          NavDestination(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'home'.tr,
          ),
          NavDestination(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'categories'.tr,
          ),
          NavDestination(
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart_rounded,
            label: 'cart'.tr,
            isCenter: true,
          ),
          NavDestination(
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            label: 'messages'.tr,
          ),
          NavDestination(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'profile'.tr,
          ),
        ],
      ),
    );
  }
}
