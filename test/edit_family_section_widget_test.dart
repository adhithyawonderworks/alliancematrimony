import 'dart:convert';

import 'package:adithyamatrimony/presentation/my_profile_screen/widgets/edit_family_section_widget.dart';
import 'package:adithyamatrimony/presentation/my_profile_screen/widgets/edit_personal_section_widget.dart';
import 'package:adithyamatrimony/presentation/my_profile_screen/my_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('structured family details round-trip through profile maps', () {
    final profile = MyProfileData.fromMap({
      'father_name': 'Ravi',
      'father_is_deceased': true,
      'father_job': 'Teacher',
      'mother_name': 'Meena',
      'mother_is_deceased': false,
      'mother_job': 'Doctor',
      'siblings': [
        {
          'name': 'Arun',
          'relationship': 'Brother',
          'isMarried': true,
          'job': 'Engineer',
          'hasChildren': true,
        },
      ],
    });

    final saved = profile.toSupabaseMap();
    expect(saved['father_name'], 'Ravi');
    expect(saved['father_is_deceased'], isTrue);
    expect(saved['mother_name'], 'Meena');
    expect(saved['siblings'], profile.siblings);
  });

  test('extended profile preferences round-trip through Supabase fields', () {
    final profile = MyProfileData.fromMap({
      'school_name': 'North School',
      'college_name': 'City College',
      'university_name': 'State University',
      'primary_address_stay_period': 'Since birth',
      'current_city_same_as_primary_address': true,
      'partner_age_min': '25',
      'partner_age_max': '32',
      'partner_height_cm': '165',
      'partner_height_feet': '5',
      'partner_height_inches': '5',
      'partner_religion_mode': 'religion_caste',
      'partner_caste': 'Other',
      'partner_location_mode': 'India',
      'partner_state': 'Tamil Nadu',
      'partner_district': 'No district preference',
      'partner_language': 'Tamil',
      'partner_languages': 'Tamil, English',
    });

    final saved = profile.toSupabaseMap();
    expect(saved['school_name'], 'North School');
    expect(saved['college_name'], 'City College');
    expect(saved['university_name'], 'State University');
    expect(saved['primary_address_stay_period'], 'Since birth');
    expect(saved['current_city_same_as_primary_address'], isTrue);
    expect(saved['partner_age_min'], '25');
    expect(saved['partner_height_feet'], '5');
    expect(saved['partner_religion_mode'], 'religion_caste');
    expect(saved['partner_state'], 'Tamil Nadu');
    expect(saved['partner_languages'], 'Tamil, English');
  });

  testWidgets('sibling details can be added and emitted', (tester) async {
    Map<String, String> changedValues = {};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EditFamilySectionWidget(
              initialValues: const {},
              onChanged: (values) => changedValues = values,
            ),
          ),
        ),
      ),
    );

    expect(find.text("Father's Details"), findsOneWidget);
    expect(find.text("Mother's Details"), findsOneWidget);
    expect(find.text('Passed away'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Add sibling'));
    await tester.pumpAndSettle();
    expect(find.text('Sibling 1'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(4), 'Arun');

    final siblings = jsonDecode(changedValues['siblings']!) as List;
    expect(siblings, hasLength(1));
    expect(siblings.single['name'], 'Arun');
    expect(siblings.single['relationship'], 'Brother');
    expect(siblings.single['isMarried'], isFalse);
    expect(siblings.single['hasChildren'], isFalse);
  });

  testWidgets('custom occupation and education values remain editable', (
    tester,
  ) async {
    Map<String, String> changedValues = {};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EditPersonalSectionWidget(
              initialValues: const {
                'job': 'Custom occupation',
                'education': 'Custom qualification',
              },
              onChanged: (values) => changedValues = values,
            ),
          ),
        ),
      ),
    );

    final occupationField = find.byWidgetPredicate(
      (widget) =>
          widget is TextFormField &&
          widget.decoration.hintText == 'Enter your occupation',
    );
    final educationField = find.byWidgetPredicate(
      (widget) =>
          widget is TextFormField &&
          widget.decoration.hintText == 'Enter your education',
    );

    expect(occupationField, findsOneWidget);
    expect(educationField, findsOneWidget);

    await tester.enterText(occupationField, 'Independent consultant');
    await tester.enterText(educationField, 'Diploma in textile design');

    expect(changedValues['job'], 'Independent consultant');
    expect(changedValues['education'], 'Diploma in textile design');
  });

  testWidgets('education institutions and same-address choice are collected', (
    tester,
  ) async {
    Map<String, String> changedValues = {};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EditPersonalSectionWidget(
              initialValues: const {'currentCitySameAsPrimaryAddress': 'true'},
              onChanged: (values) => changedValues = values,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Current City'), findsNothing);
    expect(find.text('Duration of Stay'), findsNothing);
    expect(find.text('Primary Address Stay Period'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextFormField &&
            widget.decoration.hintText == 'School name',
      ),
      'North School',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextFormField &&
            widget.decoration.hintText == 'College name',
      ),
      'City College',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextFormField &&
            widget.decoration.hintText == 'University name',
      ),
      'State University',
    );

    expect(changedValues['currentCitySameAsPrimaryAddress'], 'true');
    expect(changedValues['schoolName'], 'North School');
    expect(changedValues['collegeName'], 'City College');
    expect(changedValues['universityName'], 'State University');
  });
}
