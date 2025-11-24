import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:reliefflow_frontend_public_app/screens/home/home_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/request_donation.dart';
import 'package:reliefflow_frontend_public_app/screens/views/request_aid.dart';

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

  List<Widget> _screens() {
    return [
      const HomeScreen(),
      Container(), // placeholder for middle button
      Container(),
      const RequestDonation(),
      const RequestAidScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),

      /// Fake item just for spacing
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.request_page,
        ),
        title: 'Aids',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),

      /// Center + Button (will trigger star menu)
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add, size: 35),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
        onPressed: (context) {
          // We won't use this anymore, because we use the floating StarMenu.
        },
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
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _screens(),
        items: _navItems(),
        navBarStyle: NavBarStyle.style15,
        backgroundColor: Colors.white,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(0),
          colorBehindNavBar: Colors.white,
        ),
        hideNavigationBarWhenKeyboardAppears: true,
      ),
    );
  }
}

/// =====================================================
/// ⭐ Floating Star Menu
/// =====================================================
class _StarMenu extends StatefulWidget {
  final VoidCallback onAidClick;
  final VoidCallback onDonationClick;

  const _StarMenu({
    required this.onAidClick,
    required this.onDonationClick,
  });

  @override
  State<_StarMenu> createState() => _StarMenuState();
}

class _StarMenuState extends State<_StarMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleMenu() {
    if (isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => isOpen = !isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 200,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 70,
              child: ScaleTransition(
                scale: _animation,
                child: FloatingActionButton.extended(
                  heroTag: "aid",
                  onPressed: () {
                    toggleMenu();
                    widget.onAidClick();
                  },
                  backgroundColor: Colors.blue,
                  label: const Text("Request Aid"),
                  icon: const Icon(Icons.add_a_photo),
                ),
              ),
            ),

            Positioned(
              bottom: 140,
              child: ScaleTransition(
                scale: _animation,
                child: FloatingActionButton.extended(
                  heroTag: "donation",
                  onPressed: () {
                    toggleMenu();
                    widget.onDonationClick();
                  },
                  backgroundColor: Colors.green,
                  label: const Text("Request Donation"),
                  icon: const Icon(Icons.volunteer_activism),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
