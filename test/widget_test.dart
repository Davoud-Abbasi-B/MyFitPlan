import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/app.dart';

void main() {
  testWidgets('Fitora root application builds successfully', (tester) async {
    Widget? builtApp;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          builtApp = const MyFitPlanApp().build(context);
          return const SizedBox.shrink();
        },
      ),
    );

    expect(builtApp, isA<MaterialApp>());
    final app = builtApp! as MaterialApp;
    expect(app.title, 'Fitora');
    expect(app.locale, const Locale('fa'));
    expect(app.home, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
