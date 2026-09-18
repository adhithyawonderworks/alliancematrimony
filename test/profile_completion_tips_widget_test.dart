import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adithyamatrimony/presentation/my_profile_screen/my_profile_screen.dart';
import 'package:adithyamatrimony/presentation/my_profile_screen/widgets/profile_completion_tips_widget.dart';

void main() {
  testWidgets('profile completion tips show missing items for an incomplete profile', (tester) async {
    const profile = MyProfileData(
      firstName: 'Asha',
      lastName: 'Nair',
      age: 28,
      gender: 'Female',
      dob: '10 August 1997',
      job: 'Product Designer',
      education: 'B.Des',
      place: 'Kochi',
      heightCm: '160 cm',
      weightKg: '52 kg',
      religion: '',
      caste: '',
      motherTongue: 'Malayalam',
      facebookLink: '',
      parentsName: '',
      parentsJob: '',
      email: 'asha@example.com',
      phone: '+91 98765 43210',
      imageUrl: '',
      semanticLabel: 'Test profile',
      isPaid: false,
      isVerified: true,
      referralCode: 'ASHA2026',
      referralCount: 2,
      referralCredits: 150,
      partnerAgeRange: '',
      partnerHeightRange: '',
      partnerReligion: '',
      partnerPlace: '',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileCompletionTipsWidget(profile: profile),
        ),
      ),
    );

    expect(find.text('Add your photo'), findsOneWidget);
    expect(find.text('Complete your religion details'), findsOneWidget);
  });
}
