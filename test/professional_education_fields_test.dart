import 'package:adithyamatrimony/presentation/my_profile_screen/widgets/edit_personal_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
