// Basic smoke tests for the Communal app shell.

import 'package:communal/dark_theme.dart';
import 'package:communal/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light and dark themes expose the expected brightness', () {
    expect(lightTheme.brightness, Brightness.light);
    expect(darkTheme.brightness, Brightness.dark);
  });

  testWidgets('a MaterialApp renders with the app light theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: const Scaffold(
          body: Center(child: Text('Communal')),
        ),
      ),
    );

    expect(find.text('Communal'), findsOneWidget);
  });
}
