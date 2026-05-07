// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cini_find/main.dart';

void main() {
  testWidgets('CiniFind app smoke test', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const Text('LOGIN'),
        ),
      ],
    );

    await tester.pumpWidget(
      CiniFindApp(router: router),
    );

    expect(find.text('LOGIN'), findsOneWidget);
  });
}
