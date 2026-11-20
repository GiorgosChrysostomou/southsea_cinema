import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking.dart';

void main() {
  final DateTime date = DateTime(2026, 10, 22, 18, 0);

  group('Booking constructor', () {
    test('assigns all properties', () {
      final booking = Booking(
        id: 7,
        bookingNumber: 'SC-0001',
        summary: '2 x Dracula (1931)',
        total: 15.0,
        date: date,
      );

      expect(booking.id, 7);
      expect(booking.bookingNumber, 'SC-0001');
      expect(booking.summary, '2 x Dracula (1931)');
      expect(booking.total, 15.0);
      expect(booking.date, date);
    });

    test('id is optional and defaults to null', () {
      final booking = Booking(
        bookingNumber: 'SC-0002',
        summary: '1 x Halloween (1978)',
        total: 7.5,
        date: date,
      );

      expect(booking.id, isNull);
    });
  });

  group('Booking.toMap', () {
    test('contains all fields', () {
      final booking = Booking(
        id: 7,
        bookingNumber: 'SC-0001',
        summary: '2 x Dracula (1931)',
        total: 15.0,
        date: date,
      );

      expect(booking.toMap(), {
        'id': 7,
        'bookingNumber': 'SC-0001',
        'summary': '2 x Dracula (1931)',
        'total': 15.0,
        'date': date.toIso8601String(),
      });
    });

    test('has a null id when the booking is not saved yet', () {
      final booking = Booking(
        bookingNumber: 'SC-0002',
        summary: '1 x Halloween (1978)',
        total: 7.5,
        date: date,
      );

      expect(booking.toMap()['id'], isNull);
    });

    test('stores the date as an ISO 8601 string', () {
      final booking = Booking(
        bookingNumber: 'SC-0003',
        summary: '3 x Dracula (1931)',
        total: 22.5,
        date: date,
      );

      expect(booking.toMap()['date'], isA<String>());
      expect(booking.toMap()['date'], '2026-10-22T18:00:00.000');
    });
  });

  group('Booking.fromMap', () {
    test('reads all fields', () {
      final booking = Booking.fromMap({
        'id': 3,
        'bookingNumber': 'SC-0003',
        'summary': '3 x Dracula (1931)',
        'total': 22.5,
        'date': '2026-10-22T18:00:00.000',
      });

      expect(booking.id, 3);
      expect(booking.bookingNumber, 'SC-0003');
      expect(booking.summary, '3 x Dracula (1931)');
      expect(booking.total, 22.5);
      expect(booking.date, DateTime(2026, 10, 22, 18, 0));
    });

    test('accepts a null id', () {
      final booking = Booking.fromMap({
        'id': null,
        'bookingNumber': 'SC-0004',
        'summary': '1 x Halloween (1978)',
        'total': 7.5,
        'date': '2026-10-31T21:00:00.000',
      });

      expect(booking.id, isNull);
    });

    test('accepts a whole-number total from the database', () {
      final booking = Booking.fromMap({
        'id': 5,
        'bookingNumber': 'SC-0005',
        'summary': '2 x Halloween (1978)',
        'total': 15,
        'date': '2026-10-31T21:00:00.000',
      });

      expect(booking.total, 15.0);
      expect(booking.total, isA<double>());
    });
  });

  group('Booking round trip', () {
    test('toMap then fromMap keeps every field', () {
      final original = Booking(
        id: 9,
        bookingNumber: 'SC-0009',
        summary: '2 x Dracula (1931), 1 x Halloween (1978)',
        total: 22.5,
        date: date,
      );

      final copy = Booking.fromMap(original.toMap());

      expect(copy.id, original.id);
      expect(copy.bookingNumber, original.bookingNumber);
      expect(copy.summary, original.summary);
      expect(copy.total, original.total);
      expect(copy.date, original.date);
    });

    test('round trip keeps a null id', () {
      final original = Booking(
        bookingNumber: 'SC-0010',
        summary: '1 x Dracula (1931)',
        total: 7.5,
        date: date,
      );

      final copy = Booking.fromMap(original.toMap());

      expect(copy.id, isNull);
      expect(copy.bookingNumber, 'SC-0010');
    });
  });

  group('Booking formattedTotal', () {
    test('shows a whole-pound total with two decimals', () {
      final booking = Booking(
        bookingNumber: 'SC-0011',
        summary: '2 x Halloween (1978)',
        total: 15,
        date: date,
      );

      expect(booking.formattedTotal, '£15.00');
    });

    test('shows a total with pence with two decimals', () {
      final booking = Booking(
        bookingNumber: 'SC-0012',
        summary: '1 x Dracula (1931)',
        total: 7.5,
        date: date,
      );

      expect(booking.formattedTotal, '£7.50');
    });
  });
}
