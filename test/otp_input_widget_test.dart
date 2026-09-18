import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adithyamatrimony/presentation/sign_up_login_screen/widgets/otp_input_widget.dart';

void main() {
  testWidgets('resend clears the currently entered OTP digits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpInputWidget(
            phoneOtpVerified: false,
            emailOtpVerified: false,
            onPhoneVerified: () {},
            onEmailVerified: () {},
          ),
        ),
      ),
    );

    final phoneField = find.byType(TextFormField).at(0);
    await tester.enterText(phoneField, '1');
    await tester.pump();

    await tester.tap(find.text('Resend').first);
    await tester.pump();

    expect((tester.widget<TextFormField>(phoneField).controller?.text ?? ''), isEmpty);
  });

  testWidgets('verify otp ignores incomplete digits', (tester) async {
    var verified = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpInputWidget(
            phoneOtpVerified: false,
            emailOtpVerified: false,
            onPhoneVerified: () => verified = true,
            onEmailVerified: () {},
          ),
        ),
      ),
    );

    final phoneField = find.byType(TextFormField).at(0);
    await tester.enterText(phoneField, '1');
    await tester.pump();

    await tester.tap(find.text('Verify OTP').first);
    await tester.pump();

    expect(verified, isFalse);
  });

  testWidgets('verify otp triggers callback when all six digits are entered', (tester) async {
    var verified = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpInputWidget(
            phoneOtpVerified: false,
            emailOtpVerified: false,
            onPhoneVerified: () => verified = true,
            onEmailVerified: () {},
          ),
        ),
      ),
    );

    final fields = find.byType(TextFormField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(fields.at(i), (i + 1).toString());
    }
    await tester.pump();

    await tester.tap(find.text('Verify OTP').first);
    await tester.pump();

    expect(verified, isTrue);
  });
}
