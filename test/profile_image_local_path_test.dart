import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:adithyamatrimony/presentation/my_profile_screen/my_profile_screen.dart';
import 'package:adithyamatrimony/presentation/my_profile_screen/widgets/profile_hero_widget.dart';
import 'package:adithyamatrimony/presentation/sign_up_login_screen/widgets/signup_fields_widget.dart';

void main() {
  testWidgets('profile hero renders local file images as file images', (tester) async {
    final file = File('${Directory.systemTemp.path}/profile_test.png');
    await file.writeAsBytes(List<int>.filled(1024, 0));

    final profile = MyProfileData.fromMap({
      'firstName': 'Asha',
      'lastName': 'Nair',
      'age': 28,
      'gender': 'Female',
      'dob': '10 August 1997',
      'job': 'Product Designer',
      'education': 'B.Des',
      'place': 'Kochi',
      'heightCm': '160 cm',
      'weightKg': '52 kg',
      'religion': 'Hindu',
      'caste': 'Nair',
      'motherTongue': 'Malayalam',
      'facebookLink': '',
      'parentsName': 'Raju Nair',
      'parentsJob': 'Business',
      'email': 'asha@example.com',
      'phone': '+91 98765 43210',
      'imageUrl': file.path,
      'semanticLabel': 'Test profile',
      'isPaid': false,
      'isVerified': true,
      'referralCode': 'ASHA2026',
      'referralCount': 2,
      'referralCredits': 150,
      'partnerAgeRange': '26-32',
      'partnerHeightRange': '160 cm and above',
      'partnerReligion': 'Hindu',
      'partnerPlace': 'Kerala',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileHeroWidget(
            profile: profile,
            completenessPercent: 75,
          ),
        ),
      ),
    );

    final images = tester.widgetList<Image>();
    final hasLocalFileImage = images.any((widget) => widget.image is FileImage);

    expect(hasLocalFileImage, isTrue,
        reason: 'Profile hero should render local image file paths using FileImage.');
  });

  testWidgets('signup fields render a selected local profile photo using FileImage', (tester) async {
    final file = File('${Directory.systemTemp.path}/signup_photo.png');
    await file.writeAsBytes(List<int>.filled(1024, 0));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignupFieldsWidget(
            formKey: GlobalKey<FormState>(),
            selectedImageFile: XFile(file.path),
            onDataChanged: (_) {},
          ),
        ),
      ),
    );

    final images = tester.widgetList<Image>();
    final hasSelectedLocalPhoto = images.any((widget) => widget.image is FileImage);

    expect(hasSelectedLocalPhoto, isTrue,
        reason: 'Signup profile upload should show the selected local image in the preview.');
  });
}
