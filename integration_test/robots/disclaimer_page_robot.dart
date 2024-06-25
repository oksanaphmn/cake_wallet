import 'package:cake_wallet/src/screens/disclaimer/disclaimer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../components/common_checks.dart';

class DisclaimerPageRobot {
  DisclaimerPageRobot(this.tester) : commonTestCases = CommonTestCases(tester);

  final WidgetTester tester;
  late CommonTestCases commonTestCases;

  Future<void> isDisclaimerPage() async {
    await commonTestCases.isSpecificPage<DisclaimerPage>();
  }

  void hasCheckIcon(bool hasBeenTapped) {
    // The checked Icon should not be available initially, until user taps the checkbox
    final checkIcon = find.byKey(ValueKey('disclaimer_check_icon_key'));
    expect(checkIcon, hasBeenTapped ? findsOneWidget : findsNothing);
  }

  void hasDisclaimerCheckbox() {
    final checkBox = find.byKey(ValueKey('disclaimer_check_key'));
    expect(checkBox, findsOneWidget);
  }

  Future<void> tapDisclaimerCheckbox() async {
    final checkBox = find.byKey(ValueKey('disclaimer_check_key'));
    await tester.tap(checkBox);
    await tester.pumpAndSettle();
    await commonTestCases.defaultSleepTime();
  }

  Future<void> tapAcceptButton() async {
    final checkBox = find.byKey(ValueKey('disclaimer_accept_button_key'));
    await tester.tap(checkBox);
    await tester.pumpAndSettle();
  }
}
