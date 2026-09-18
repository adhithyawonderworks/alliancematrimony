import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:adithyamatrimony/presentation/premium_landing_screen/premium_landing_screen.dart';
import 'package:adithyamatrimony/presentation/premium_purchases_screen/premium_purchases_screen.dart';
import 'package:adithyamatrimony/routes/app_routes.dart';

void main() {
  testWidgets('premium purchase flow opens the premium landing view', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.premiumPurchasesScreen,
      routes: [
        GoRoute(
          path: AppRoutes.premiumPurchasesScreen,
          builder: (context, state) => const PremiumPurchasesScreen(),
        ),
        GoRoute(
          path: AppRoutes.premiumLandingScreen,
          builder: (context, state) => const PremiumLandingScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    expect(find.text('View Now'), findsWidgets);

    await tester.tap(find.text('View Now').first);
    await tester.pumpAndSettle();

    expect(find.text('Alliance Matrimony Premium'), findsOneWidget);
  });
}
