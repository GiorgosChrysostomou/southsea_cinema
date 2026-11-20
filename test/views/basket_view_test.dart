import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/models/booking.dart';

import '../helpers/fake_cinema_database.dart';

void main() {
  late Movie movie;

  setUp(() {
    basketRepository.clearBasket();

    movie = Movie(
      id: '1',
      title: 'The Batman',
      synopsis: 'A superhero film',
      ageRating: '12A',
      runtime: '2h 56m',
      screeningTime: '18:00',
      ticketPrice: 10.00,
      posterPath: 'assets/batman.jpg',
    );
  });

  Future<void> pumpBasket(
    WidgetTester tester,
    FakeCinemaDatabase database,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BasketView(database: database),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapCheckout(WidgetTester tester) async {
    await tester.ensureVisible(find.text('CHECKOUT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CHECKOUT'));
    await tester.pumpAndSettle();
  }

  group('Basket', () {
    testWidgets('Basket displays movie and total', (WidgetTester tester) async {
      basketRepository.addTicket(movie, quantity: 2);

      await pumpBasket(tester, FakeCinemaDatabase());

      expect(find.text('The Batman'), findsOneWidget);
      expect(find.textContaining('2 ticket(s)'), findsOneWidget);
      expect(find.text('Total: £20.00'), findsOneWidget);
    });

    testWidgets('Basket displays empty message', (WidgetTester tester) async {
      await pumpBasket(tester, FakeCinemaDatabase());

      expect(find.text('Your basket is empty'), findsOneWidget);
    });

    testWidgets('Delete button removes tickets', (WidgetTester tester) async {
      basketRepository.addTicket(movie, quantity: 2);

      await pumpBasket(tester, FakeCinemaDatabase());

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Your basket is empty'), findsOneWidget);
    });

    testWidgets('Clear basket button removes all tickets',
        (WidgetTester tester) async {
      basketRepository.addTicket(movie, quantity: 2);

      await pumpBasket(tester, FakeCinemaDatabase());

      await tester.tap(find.text('CLEAR BASKET'));
      await tester.pump();

      expect(find.text('Your basket is empty'), findsOneWidget);
    });
  });

  group('Past bookings', () {
    testWidgets('shows a message when there are no bookings',
        (WidgetTester tester) async {
      await pumpBasket(tester, FakeCinemaDatabase());

      expect(find.text('Past Bookings'), findsOneWidget);
      expect(find.text('You have no past bookings yet'), findsOneWidget);
    });

    testWidgets('lists saved bookings with the highest number first',
        (WidgetTester tester) async {
      await pumpBasket(tester, FakeCinemaDatabase(withSamples: true));

      expect(find.text('You have no past bookings yet'), findsNothing);
      expect(find.text('Booking SC-0003'), findsOneWidget);
      expect(find.text('Booking SC-0002'), findsOneWidget);
      expect(find.text('Booking SC-0001'), findsOneWidget);
      expect(find.textContaining('2 x Dracula (1931)'), findsOneWidget);

      final double top3 = tester.getTopLeft(find.text('Booking SC-0003')).dy;
      final double top2 = tester.getTopLeft(find.text('Booking SC-0002')).dy;
      final double top1 = tester.getTopLeft(find.text('Booking SC-0001')).dy;

      expect(top3, lessThan(top2));
      expect(top2, lessThan(top1));
    });

    testWidgets('shows an error message when bookings cannot be loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BasketView(database: BrokenCinemaDatabase()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load bookings'), findsOneWidget);
    });
  });

  group('Checkout', () {
    testWidgets('saves a numbered booking and shows its number',
        (WidgetTester tester) async {
      final FakeCinemaDatabase database = FakeCinemaDatabase();
      basketRepository.addTicket(movie, quantity: 2);

      await pumpBasket(tester, database);
      await tapCheckout(tester);

      expect(find.text('Booking SC-0001 confirmed'), findsOneWidget);

      expect(database.saved.length, 1);
      expect(database.saved.first.bookingNumber, 'SC-0001');
      expect(database.saved.first.summary, '2 x The Batman');
      expect(database.saved.first.total, 20.0);
    });

    testWidgets('continues numbering after the existing bookings',
        (WidgetTester tester) async {
      final FakeCinemaDatabase database = FakeCinemaDatabase(withSamples: true);
      basketRepository.addTicket(movie, quantity: 1);

      await pumpBasket(tester, database);
      await tapCheckout(tester);

      expect(find.text('Booking SC-0004 confirmed'), findsOneWidget);
      expect(database.saved.length, 4);
    });

    testWidgets('clears the basket after saving', (WidgetTester tester) async {
      basketRepository.addTicket(movie, quantity: 2);

      await pumpBasket(tester, FakeCinemaDatabase());
      await tapCheckout(tester);

      expect(basketRepository.items, isEmpty);
      expect(find.text('Your basket is empty'), findsOneWidget);
    });

    testWidgets('the new booking appears in the past bookings list',
        (WidgetTester tester) async {
      basketRepository.addTicket(movie, quantity: 2);

      await pumpBasket(tester, FakeCinemaDatabase());

      expect(find.text('You have no past bookings yet'), findsOneWidget);

      await tapCheckout(tester);

      expect(find.text('You have no past bookings yet'), findsNothing);
      expect(find.text('Booking SC-0001'), findsOneWidget);
    });

    testWidgets('keeps the basket if the booking cannot be saved',
        (WidgetTester tester) async {
      final FakeCinemaDatabase database = FakeCinemaDatabase(failSaving: true);
      basketRepository.addTicket(movie, quantity: 2);

      await pumpBasket(tester, database);
      await tapCheckout(tester);

      expect(find.text('Could not save booking'), findsOneWidget);
      expect(basketRepository.items.length, 1);
      expect(basketRepository.totalTickets, 2);
      expect(database.saved, isEmpty);
    });

    testWidgets('a saved booking is still listed when the page is reopened',
        (WidgetTester tester) async {
      final FakeCinemaDatabase database = FakeCinemaDatabase();
      basketRepository.addTicket(movie, quantity: 2);

      await pumpBasket(tester, database);
      await tapCheckout(tester);

      // Close the page completely, then open a new one.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await pumpBasket(tester, database);

      expect(find.text('Booking SC-0001'), findsOneWidget);
      expect(find.text('Your basket is empty'), findsOneWidget);
    });
  });
}

// A database that always fails to load bookings.
class BrokenCinemaDatabase extends FakeCinemaDatabase {
  @override
  Future<List<Booking>> getAllBookings() async {
    throw Exception('could not read');
  }
}
