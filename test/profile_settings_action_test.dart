import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adithyamatrimony/presentation/my_profile_screen/my_profile_screen.dart';
import 'package:adithyamatrimony/presentation/my_profile_screen/widgets/profile_hero_widget.dart';

void main() {
  testWidgets('profile hero settings action callback fires when settings icon is tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileHeroWidget(
            profile: MyProfileData(
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
              religion: 'Hindu',
              caste: 'Nair',
              motherTongue: 'Malayalam',
              facebookLink: '',
              parentsName: 'Raju Nair',
              parentsJob: 'Business',
              email: 'asha@example.com',
              phone: '+91 98765 43210',
              imageUrl: '',
              semanticLabel: 'Test profile',
              isPaid: false,
              isVerified: true,
              referralCode: 'ASHA2026',
              referralCount: 2,
              referralCredits: 150,
              partnerAgeRange: '26-32',
              partnerHeightRange: '160 cm and above',
              partnerReligion: 'Hindu',
              partnerPlace: 'Kerala',
            ),
            completenessPercent: 75,
            onSettingsTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
