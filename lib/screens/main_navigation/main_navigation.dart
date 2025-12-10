import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:reliefflow_frontend_public_app/screens/Profile/account_page.dart';
import 'package:reliefflow_frontend_public_app/screens/views/aid_request_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/views/donation_request_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/home/home_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.request_page),
        title: 'Aids',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.volunteer_activism),
        title: "Donations",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: "Profile",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.custom(
      context,
      controller: _controller,
      itemCount: _navBarsItems().length,
      screens: [
        CustomNavBarScreen(screen: const HomeScreen()),
        CustomNavBarScreen(screen: const AidsScreen()),
        CustomNavBarScreen(screen: const DonationsScreen()),
        CustomNavBarScreen(screen: const Account()), // Profile screen
      ],
      confineToSafeArea: true,
      handleAndroidBackButtonPress: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      customWidget: CustomNavBar(
        items: _navBarsItems(),
        selectedIndex: _controller.index,
        onItemSelected: (index) {
          setState(() {
            _controller.index = index;
          });
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

/// Custom Navigation Bar without StarMenu embedded
class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<PersistentBottomNavBarItem> items;
  final ValueChanged<int> onItemSelected;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  });

  Widget _buildNavItem(
    PersistentBottomNavBarItem item,
    bool isSelected,
    int index,
  ) {
    // Regular nav items
    return Container(
      alignment: Alignment.center,
      height: 60.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: IconTheme(
              data: IconThemeData(
                size: 26.0,
                color: isSelected
                    ? item.activeColorPrimary
                    : item.inactiveColorPrimary ?? item.activeColorPrimary,
              ),
              child: item.icon,
            ),
          ),
          if (item.title != null)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Material(
                type: MaterialType.transparency,
                child: FittedBox(
                  child: Text(
                    item.title!,
                    style: TextStyle(
                      color: isSelected
                          ? item.activeColorPrimary
                          : item.inactiveColorPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              int index = entry.key;
              PersistentBottomNavBarItem item = entry.value;
              return Flexible(
                child: GestureDetector(
                  onTap: () => onItemSelected(index),
                  child: _buildNavItem(
                    item,
                    selectedIndex == index,
                    index,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
