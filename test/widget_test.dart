// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:decodable_reader_app/main.dart';
import 'package:decodable_reader_app/providers/story_provider.dart';

void main() {
  testWidgets('App loads and displays home screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DecodableReaderApp());

    // Wait for the provider to initialize
    await tester.pumpAndSettle();

    // Verify that the home screen loads
    expect(find.text('Decodable Reader'), findsOneWidget);
    expect(find.text('Learn to read with phonics!'), findsOneWidget);
  });

  testWidgets('Levels are displayed correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const DecodableReaderApp());
    await tester.pumpAndSettle();

    // Check that levels are displayed
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
  });

  testWidgets('Navigation to level screen works', (WidgetTester tester) async {
    await tester.pumpWidget(const DecodableReaderApp());
    await tester.pumpAndSettle();

    // Tap on Level 1
    await tester.tap(find.text('Level 1'));
    await tester.pumpAndSettle();

    // Verify we're on the level screen
    expect(find.text('Learning: s, a, t, p, i, n'), findsOneWidget);
  });
}
