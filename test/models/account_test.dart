import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/account.dart';

void main() {
  group('Account', () {
    group('serialization', () {
      test('toMap and fromMap roundtrip preserves all fields', () {
        final original = Account(
          id: 1,
          name: 'Main Account',
          createdAt: DateTime(2025, 1, 15, 10, 30),
        );

        final map = original.toMap();
        final restored = Account.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.createdAt, original.createdAt);
      });

      test('toMap excludes id when null', () {
        final account = Account(
          name: 'New Account',
        );

        final map = account.toMap();

        expect(map.containsKey('id'), isFalse);
        expect(map['name'], 'New Account');
      });

      test('fromMap handles all fields correctly', () {
        final map = {
          'id': 1,
          'name': 'Test Account',
          'created_at': '2025-01-15T10:30:00.000',
        };

        final account = Account.fromMap(map);

        expect(account.id, 1);
        expect(account.name, 'Test Account');
        expect(account.createdAt, DateTime(2025, 1, 15, 10, 30));
      });
    });

    group('copyWith', () {
      test('creates modified copy with new name', () {
        final original = Account(
          id: 1,
          name: 'Original Name',
          createdAt: DateTime(2025, 1, 15),
        );

        final copy = original.copyWith(name: 'New Name');

        expect(copy.id, original.id);
        expect(copy.name, 'New Name');
        expect(copy.createdAt, original.createdAt);
      });

      test('creates modified copy with new id', () {
        final original = Account(
          id: 1,
          name: 'Test Account',
          createdAt: DateTime(2025, 1, 15),
        );

        final copy = original.copyWith(id: 2);

        expect(copy.id, 2);
        expect(copy.name, original.name);
        expect(copy.createdAt, original.createdAt);
      });

      test('preserves all fields when no changes specified', () {
        final original = Account(
          id: 1,
          name: 'Test Account',
          createdAt: DateTime(2025, 1, 15, 10, 30),
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.createdAt, original.createdAt);
      });
    });

    group('constructor', () {
      test('sets createdAt to now when not provided', () {
        final before = DateTime.now();
        final account = Account(name: 'Test Account');
        final after = DateTime.now();

        expect(account.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(account.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('accepts custom createdAt value', () {
        final customDate = DateTime(2025, 6, 15);
        final account = Account(
          name: 'Test Account',
          createdAt: customDate,
        );

        expect(account.createdAt, customDate);
      });

      test('id is null by default', () {
        final account = Account(name: 'Test Account');

        expect(account.id, isNull);
      });
    });
  });
}
