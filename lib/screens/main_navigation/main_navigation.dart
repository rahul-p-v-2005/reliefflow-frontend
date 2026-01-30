import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reliefflow_frontend_public_app/screens/profile/account_page.dart';
import 'package:reliefflow_frontend_public_app/screens/profile/cubit/account_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/tips/tips_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/requests_list_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/notifications/cubit/notification_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/home/home_screen.dart';
import 'package:reliefflow_frontend_public_app/services/auth_service.dart';
import 'package:reliefflow_frontend_public_app/services/fcm_service.dart';
import 'package:reliefflow_frontend_public_app/theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool _fcmCallbacksSetup = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const RequestListScreen(),
    const TipsScreen(),
    const AccountPage(),
  ];

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
            child: Scaffold(
              extendBody: true,
              body: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                ),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  children: _pages,
                ),
              ),
              bottomNavigationBar: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: AppTheme.primaryColor,
                    unselectedItemColor: AppTheme.textMuted,
                    currentIndex: _currentIndex,
                    selectedLabelStyle: AppTheme.mainFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: AppTheme.mainFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: (index) {
                      setState(() => _currentIndex = index);
                      _pageController.jumpToPage(index);
                    },
                    items: [
                      _buildNavItem(
                        Icons.home_rounded,
                        Icons.home_outlined,
                        'Home',
                        0,
                      ),
                      _buildNavItem(
                        Icons.description_rounded,
                        Icons.description_outlined,
                        'Requests',
                        1,
                      ),
                      _buildNavItem(
                        Icons.volunteer_activism_rounded,
                        Icons.volunteer_activism_outlined,
                        'Tips',
                        2,
                      ),
                      _buildNavItem(
                        Icons.person_rounded,
                        Icons.person_outline_rounded,
                        'Profile',
                        3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            key: ValueKey<bool>(isSelected),
            size: 24,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
          ),
        ),
      ),
      label: label,
    );
  }
}
