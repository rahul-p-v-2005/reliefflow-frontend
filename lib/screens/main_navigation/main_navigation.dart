import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:reliefflow_frontend_public_app/screens/profile/account_page.dart';
import 'package:reliefflow_frontend_public_app/screens/profile/cubit/account_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/tips/tips_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/requests_list_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/notifications/cubit/notification_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/home/home_screen.dart';
import 'package:reliefflow_frontend_public_app/services/auth_service.dart';
import 'package:reliefflow_frontend_public_app/services/fcm_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late PersistentTabController _controller;
  bool _fcmCallbacksSetup = false;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  /// Set up FCM callbacks to refresh notifications when push arrives
  void _setupFcmCallbacks(BuildContext context) {
    if (_fcmCallbacksSetup) return;
    _fcmCallbacksSetup = true;

    FcmService().onNotificationReceived = () {
      // Refresh notification cubit when push arrives
      if (context.mounted) {
        context.read<NotificationCubit>().silentRefresh();
      }
    };
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
        title: 'Requests',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.volunteer_activism),
        title: "Tips",
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AccountCubit()..loadAccountDetails(),
        ),
        BlocProvider(
          create: (context) => RequestsListCubit()..loadRequests(),
        ),
        BlocProvider(
          create: (context) => NotificationCubit()..loadNotifications(),
        ),
      ],
      // Global listener for 401 Unauthorized errors from all cubits
      child: Builder(
        builder: (builderContext) {
          // Set up FCM callbacks after bloc providers are available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _setupFcmCallbacks(builderContext);
          });

          return MultiBlocListener(
            listeners: [
              BlocListener<RequestsListCubit, RequestsListState>(
                listenWhen: (previous, current) =>
                    current is RequestsListError && current.statusCode == 401,
                listener: (context, state) {
                  AuthService().handleUnauthorized(context);
                },
              ),
              BlocListener<AccountCubit, AccountState>(
                listenWhen: (previous, current) =>
                    current is AccountError && current.statusCode == 401,
                listener: (context, state) {
                  AuthService().handleUnauthorized(context);
                },
              ),
              BlocListener<NotificationCubit, NotificationState>(
                listenWhen: (previous, current) =>
                    current is NotificationError && current.statusCode == 401,
                listener: (context, state) {
                  AuthService().handleUnauthorized(context);
                },
              ),
            ],
            child: PersistentTabView.custom(
              builderContext,
              controller: _controller,
              itemCount: _navBarsItems().length,
              screens: [
                CustomNavBarScreen(screen: const HomeScreen()),
                CustomNavBarScreen(screen: const RequestListScreen()),
                CustomNavBarScreen(screen: const TipsScreen()),
                CustomNavBarScreen(
                  screen: const AccountPage(),
                ), // Profile screen
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
            ),
          );
        },
      ),
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
