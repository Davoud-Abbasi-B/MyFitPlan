import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/features/dashboard/screens/dashboard_screen.dart';

void main() {
  Widget testHost(Widget child, {double width = 320}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );
  }

  group('dashboard score spark bars', () {
    testWidgets('renders one compact fixed-width bar', (tester) async {
      await tester.pumpWidget(testHost(
        buildDashboardSparkBarsForTest([75], maxValue: 100),
      ));

      final bars = find.byKey(const ValueKey('dashboard-score-bar'));
      expect(bars, findsOneWidget);
      expect(tester.getSize(bars).width, 10);
      expect(find.byType(Expanded), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders two compact fixed-width bars', (tester) async {
      await tester.pumpWidget(testHost(
        buildDashboardSparkBarsForTest([45, 80], maxValue: 100),
      ));

      final bars = find.byKey(const ValueKey('dashboard-score-bar'));
      expect(bars, findsNWidgets(2));
      for (final element in bars.evaluate()) {
        expect(
            tester.getSize(find.byElementPredicate((e) => e == element)).width,
            10);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('many values remain compact and scroll when needed',
        (tester) async {
      await tester.pumpWidget(testHost(
        buildDashboardSparkBarsForTest(
          List<double>.generate(40, (index) => 30 + index.toDouble()),
          maxValue: 100,
        ),
        width: 320,
      ));

      expect(
        find.byKey(const ValueKey('dashboard-score-bar')),
        findsNWidgets(40),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('dashboard line sparklines', () {
    testWidgets('one value renders one centered latest marker', (tester) async {
      await tester.pumpWidget(testHost(
        buildDashboardLineSparklineForTest([87]),
      ));

      final marker = find.byKey(
        const ValueKey('dashboard-latest-value-marker'),
      );
      expect(marker, findsOneWidget);
      final markerWidget = tester.widget<Positioned>(marker);
      expect(markerWidget.left, closeTo(155, 0.01));
      expect(markerWidget.top, closeTo(35, 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('two values render a line with the latest marker on the right',
        (tester) async {
      await tester.pumpWidget(testHost(
        buildDashboardLineSparklineForTest([87, 86.5]),
      ));

      expect(find.byType(CustomPaint), findsWidgets);
      final marker = tester.widget<Positioned>(find.byKey(
        const ValueKey('dashboard-latest-value-marker'),
      ));
      expect(marker.left, closeTo(307, 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('decreasing weight values render without reversing or errors',
        (tester) async {
      await tester.pumpWidget(testHost(
        buildDashboardLineSparklineForTest([87, 86.5, 82.5, 81.5]),
      ));

      final marker = tester.widget<Positioned>(find.byKey(
        const ValueKey('dashboard-latest-value-marker'),
      ));
      expect(marker.left, closeTo(307, 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('equal waist values render safely at the vertical center',
        (tester) async {
      await tester.pumpWidget(testHost(
        buildDashboardLineSparklineForTest([92, 92, 92]),
      ));

      final marker = tester.widget<Positioned>(find.byKey(
        const ValueKey('dashboard-latest-value-marker'),
      ));
      expect(marker.top, closeTo(35, 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('latest value marker is rendered', (tester) async {
      await tester.pumpWidget(testHost(
        buildDashboardLineSparklineForTest([100, 96, 93, 92]),
      ));

      expect(
        find.byKey(const ValueKey('dashboard-latest-value-marker')),
        findsOneWidget,
      );
    });
  });

  testWidgets('trend card does not overflow at 320 logical pixels',
      (tester) async {
    await tester.pumpWidget(testHost(
      buildDashboardTrendCardForTest(
        values: [87, 86.5, 82.5, 81.5],
        emptyMessage: 'بدون داده',
      ),
      width: 320,
    ));

    expect(tester.takeException(), isNull);
  });

  testWidgets('empty trend keeps its existing message and stable chart height',
      (tester) async {
    const emptyMessage = 'هنوز سابقه کافی برای نمایش روند وزن وجود ندارد.';
    await tester.pumpWidget(testHost(
      buildDashboardTrendCardForTest(
        values: const [],
        emptyMessage: emptyMessage,
      ),
    ));

    expect(find.text(emptyMessage), findsOneWidget);
    expect(
      tester
          .getSize(find
              .ancestor(
                of: find.text(emptyMessage),
                matching: find.byType(SizedBox),
              )
              .first)
          .height,
      90,
    );
    expect(tester.takeException(), isNull);
  });
}
