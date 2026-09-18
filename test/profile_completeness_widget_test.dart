import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adithyamatrimony/presentation/my_profile_screen/widgets/profile_completeness_widget.dart';

void main() {
  testWidgets('profile completeness widget updates when percent changes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileCompletenessWidget(percent: 40),
        ),
      ),
    );

    expect(find.text('40%'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileCompletenessWidget(percent: 100),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('100%'), findsOneWidget);
  });
}
