import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:star_menu/star_menu.dart';
import 'package:reliefflow_frontend_public_app/screens/profile/account_page.dart';
import 'package:reliefflow_frontend_public_app/screens/profile/cubit/account_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/tips/tips_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/requests_list_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/notifications/cubit/notification_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/home/home_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/aid_request/request_aid_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/request_donation.dart';
import 'package:reliefflow_frontend_public_app/services/auth_service.dart';
import 'package:reliefflow_frontend_public_app/services/fcm_service.dart';
import 'package:reliefflow_frontend_public_app/theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  bool _fcmCallbacksSetup = false;
  final StarMenuController _starMenuController = StarMenuController();
  bool _isMenuOpen = false;

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
              bottomNavigationBar: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
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
                        currentIndex: _currentIndex < 2
                            ? _currentIndex
                            : _currentIndex + 1,
                        selectedLabelStyle: AppTheme.mainFont(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: AppTheme.mainFont(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: (index) {
                          if (index == 2) return; // Ignore tap on spacer
                          final actualIndex = index < 2 ? index : index - 1;
                          setState(() => _currentIndex = actualIndex);
                          _pageController.jumpToPage(actualIndex);
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
                          // Spacer item for FAB
                          const BottomNavigationBarItem(
                            icon: SizedBox(width: 40, height: 24),
                            label: '',
                          ),
                          _buildNavItem(
                            Icons.volunteer_activism_rounded,
                            Icons.volunteer_activism_outlined,
                            'Tips',
                            3,
                          ),
                          _buildNavItem(
                            Icons.person_rounded,
                            Icons.person_outline_rounded,
                            'Profile',
                            4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Star Menu FAB in center
                  Positioned(
                    bottom: 35,
                    child:
                        FloatingActionButton(
                          backgroundColor: AppTheme.primaryColor,
                          elevation: 4,
                          onPressed: () {},
                          child: AnimatedRotation(
                            turns: _isMenuOpen
                                ? 0.125
                                : 0, // 45 degrees (0.125 = 45/360)
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ).addStarMenu(
                          items: [
                            _StarMenuItem(
                              screen: const RequestDonation(),
                              label: 'Donation',
                              icon: Icons.card_giftcard,
                              requestsListCubit: builderContext
                                  .read<RequestsListCubit>(),
                            ),
                            _StarMenuItem(
                              screen: const RequestAidScreen(),
                              label: 'Aid',
                              icon: Icons.support_agent,
                              requestsListCubit: builderContext
                                  .read<RequestsListCubit>(),
                            ),
                          ],
                          // params: StarMenuParameters.arc(
                          //   ArcType.semiUp,
                          //   // radiusY: 140,
                          //   radiusX: 70,
                          // ),
                          params: StarMenuParameters(
                            backgroundParams: BackgroundParams(
                              animatedBlur: true,
                              backgroundColor: Colors.transparent,
                            ),
                            centerOffset: Offset(0, -50),
                            circleShapeParams: CircleShapeParams(
                              radiusX: 70,
                              radiusY: 70,
                            ),
                            shape: MenuShape.circle,
                          ),
                          controller: _starMenuController,
                          onStateChanged: (state) {
                            if (state == MenuState.opening) {
                              setState(() => _isMenuOpen = true);
                            } else if (state == MenuState.closing) {
                              setState(() => _isMenuOpen = false);
                            }
                          },
                          onItemTapped: (index, controller) {
                            controller.closeMenu?.call();
                          },
                        ),
                  ),
                ],
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
    int navIndex,
  ) {
    // Map nav indices (0,1,3,4) to page indices (0,1,2,3)
    final pageIndex = navIndex < 2 ? navIndex : navIndex - 1;
    final isSelected = _currentIndex == pageIndex;
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

class _StarMenuItem extends StatelessWidget {
  const _StarMenuItem({
    required this.screen,
    required this.label,
    required this.icon,
    required this.requestsListCubit,
  });

  final Widget screen;
  final String label;
  final IconData icon;
  final RequestsListCubit requestsListCubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppTheme.primaryColor,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute<dynamic>(
                  builder: (context) => screen,
                ),
              );
              if (result == true) {
                // Use the passed cubit reference to refresh
                // This ensures the refresh works regardless of context
                requestsListCubit.refresh();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTheme.mainFont(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
