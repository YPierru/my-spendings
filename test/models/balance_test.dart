import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/balance.dart';

void main() {
  group('Balance', () {
    group('serialization', () {
      test('toMap and fromMap roundtrip preserves all fields', () {
        final original = Balance(
          id: 1,
          amount: 1500.50,
          date: DateTime(2025, 1, 15),
          createdAt: DateTime(2025, 1, 15, 10, 30),
        );

        final map = original.toMap();
        final restored = Balance.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.amount, original.amount);
        expect(restored.date, original.date);
        expect(restored.createdAt, original.createdAt);
      });

      test('toMap excludes id when null', () {
        final balance = Balance(
          amount: 1000.0,
          date: DateTime(2025, 1, 1),
        );

        final map = balance.toMap();

        expect(map.containsKey('id'), isFalse);
        expect(map['amount'], 1000.0);
      });

      test('fromMap handles numeric amount correctly', () {
        final map = {
          'id': 1,
          'amount': 1234,
          'date': '2025-01-15T00:00:00.000',
          'created_at': '2025-01-15T10:30:00.000',
        };

        final balance = Balance.fromMap(map);

        expect(balance.amount, 1234.0);
      });
    });

    group('copyWith', () {
      test('creates modified copy with new amount', () {
        final original = Balance(
          id: 1,
          amount: 1500.0,
          date: DateTime(2025, 1, 15),
        );

        final copy = original.copyWith(amount: 2000.0);

        expect(copy.id, original.id);
        expect(copy.amount, 2000.0);
        expect(copy.date, original.date);
      });

      test('creates modified copy with new date', () {
        final original = Balance(
          id: 1,
          amount: 1500.0,
          date: DateTime(2025, 1, 15),
        );

        final newDate = DateTime(2025, 6, 1);
        final copy = original.copyWith(date: newDate);

        expect(copy.id, original.id);
        expect(copy.amount, original.amount);
        expect(copy.date, newDate);
      });

      test('preserves all fields when no changes specified', () {
        final original = Balance(
          id: 1,
          amount: 1500.0,
          date: DateTime(2025, 1, 15),
          createdAt: DateTime(2025, 1, 15, 10, 30),
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.amount, original.amount);
        expect(copy.date, original.date);
        expect(copy.createdAt, original.createdAt);
      });
    });

    group('constructor', () {
      test('sets createdAt to now when not provided', () {
        final before = DateTime.now();
        final balance = Balance(
          amount: 1000.0,
          date: DateTime(2025, 1, 1),
        );
        final after = DateTime.now();

        expect(balance.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(balance.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('handles negative amounts', () {
        final balance = Balance(
          amount: -500.0,
          date: DateTime(2025, 1, 1),
        );

        expect(balance.amount, -500.0);
      });

      test('handles zero amount', () {
        final balance = Balance(
          amount: 0.0,
          date: DateTime(2025, 1, 1),
        );

        expect(balance.amount, 0.0);
      });
    });
  });
}
