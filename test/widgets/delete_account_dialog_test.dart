import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/widgets/delete_account_dialog.dart';

void main() {
  group('DeleteAccountDialog', () {
    testWidgets('renders with warning message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteAccountDialog(accountName: 'Test Account'),
          ),
        ),
      );

      expect(find.text('Delete Account'), findsOneWidget);
      expect(find.textContaining('permanently delete'), findsOneWidget);
      expect(find.textContaining('Test Account'), findsWidgets);
    });

    testWidgets('delete button is initially disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteAccountDialog(accountName: 'Test Account'),
          ),
        ),
      );

      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete'),
      );
      expect(deleteButton.onPressed, isNull);
    });

    testWidgets('delete button enabled when name matches exactly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteAccountDialog(accountName: 'Test Account'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test Account');
      await tester.pump();

      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete'),
      );
      expect(deleteButton.onPressed, isNotNull);
    });

    testWidgets('delete button stays disabled with partial match', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteAccountDialog(accountName: 'Test Account'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete'),
      );
      expect(deleteButton.onPressed, isNull);
    });

    testWidgets('delete button stays disabled with case mismatch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteAccountDialog(accountName: 'Test Account'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test account');
      await tester.pump();

      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete'),
      );
      expect(deleteButton.onPressed, isNull);
    });

    testWidgets('cancel button returns false', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const DeleteAccountDialog(accountName: 'Test'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('delete button returns true when confirmed', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const DeleteAccountDialog(accountName: 'My Account'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'My Account');
      await tester.pump();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets('shows instructions to type account name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteAccountDialog(accountName: 'Test Account'),
          ),
        ),
      );

      expect(find.textContaining('Type'), findsOneWidget);
    });
  });
}
