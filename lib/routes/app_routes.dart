import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/browse_profiles_screen/browse_profiles_screen.dart';
import '../presentation/interests_screen/interests_screen.dart';
import '../presentation/matches_screen/matches_screen.dart';
import '../presentation/my_profile_screen/my_profile_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../presentation/chat_screen/chat_screen.dart';
import '../presentation/premium_landing_screen/premium_landing_screen.dart';
import '../presentation/premium_purchases_screen/premium_purchases_screen.dart';
import '../presentation/payment_result_screen/payment_result_screen.dart';
import '../presentation/notifications_screen/notifications_screen.dart';
import '../widgets/app_scaffold.dart';

class AppRoutes {
  static const String initial = '/';
  static const String signUpLoginScreen = '/sign-up-login-screen';
  static const String browseProfilesScreen = '/browse-profiles-screen';
  static const String interestsScreen = '/interests-screen';
  static const String matchesScreen = '/matches-screen';
  static const String myProfileScreen = '/my-profile-screen';
  static const String chatScreen = '/chat-screen';
  static const String notificationsScreen = '/notifications-screen';
  static const String premiumLandingScreen = '/premium-landing-screen';
  static const String premiumPurchasesScreen = '/premium-purchases-screen';
  static const String paymentResultScreen = '/payment-result-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
    GoRoute(
      path: AppRoutes.initial,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignUpLoginScreen(),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.browseProfilesScreen,
              builder: (context, state) => const BrowseProfilesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.interestsScreen,
              builder: (context, state) => const InterestsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.matchesScreen,
              builder: (context, state) => const MatchesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.chatScreen,
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.myProfileScreen,
              builder: (context, state) => const MyProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.signUpLoginScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignUpLoginScreen(),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.notificationsScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NotificationsScreen(),
        transitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.premiumLandingScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PremiumLandingScreen(),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.premiumPurchasesScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PremiumPurchasesScreen(),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.paymentResultScreen,
      builder: (context, state) {
        final status = state.uri.queryParameters['status'];
        return PaymentResultScreen(success: status == 'success');
      },
    ),
  ],
);
