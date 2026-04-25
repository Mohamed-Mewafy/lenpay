import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/ui/main/homepage.dart';
import 'package:lenpay/ui/main/widget/operations_list.dart';
import 'package:lenpay/ui/submain_page/settings.dart';
import 'package:lenpay/ui/submain_page/wallet.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // These are the screens that will swap in the body
  static final List<Widget> _pages = [
    const Homepage(), // Your custom homepage
    const Wallet(),
    const Operationslist(),
    const Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(
                alpha:
                    Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.05,
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: GNav(
            rippleColor: Theme.of(context).hoverColor,
            hoverColor: Theme.of(context).splashColor,
            gap: 8,
            activeColor: Theme.of(context).primaryColor,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor:
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            tabs: [
              GButton(icon: Icons.home, text: 'Home'.tr(context)),
              GButton(icon: Icons.wallet, text: 'Wallet'.tr(context)),
              GButton(icon: Icons.timelapse, text: 'Operations'.tr(context)),
              GButton(icon: Icons.settings, text: 'Settings'.tr(context)),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutQuart,
              );
            },
          ),
        ),
      ),
    );
  }
}
