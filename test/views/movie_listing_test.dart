import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/movie_listing.dart';

void main() {
  late Movie movie;

  setUp(() {
    basketRepository.clearBasket();
    movie = MovieRepository().getMovies().first;
  });

  Future<void> pumpListing(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MovieListing(movie: movie),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseQuantity(WidgetTester tester, String quantity) async {
    await tester.ensureVisible(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(quantity).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapAddToOrder(WidgetTester tester) async {
    final Finder addButton =
        find.widgetWithText(ElevatedButton, 'ADD TO ORDER');
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pump();
  }

  group('MovieListing', () {
    testWidgets('shows the film details', (WidgetTester tester) async {
      await pumpListing(tester);

      expect(find.text('Dracula (1931) (PG)'), findsOneWidget);
      expect(find.text(movie.synopsis), findsOneWidget);
      expect(find.text('Adult (£7.50)'), findsOneWidget);
      expect(find.text('ADD TO ORDER'), findsOneWidget);
    });

    testWidgets('ADD TO ORDER shows feedback for the chosen quantity',
        (WidgetTester tester) async {
      await pumpListing(tester);

      expect(find.text('Added 2 tickets for Dracula (1931)'), findsNothing);

      await chooseQuantity(tester, '2');
      await tapAddToOrder(tester);

      expect(find.text('Added 2 tickets for Dracula (1931)'), findsOneWidget);
    });

    testWidgets('ADD TO ORDER puts the tickets in the basket',
        (WidgetTester tester) async {
      await pumpListing(tester);

      await chooseQuantity(tester, '3');
      await tapAddToOrder(tester);

      expect(basketRepository.totalTickets, 3);
      expect(basketRepository.total, 22.5);
    });

    testWidgets('ADD TO ORDER asks for at least one ticket',
        (WidgetTester tester) async {
      await pumpListing(tester);

      await tapAddToOrder(tester);

      expect(find.text('Please select at least one ticket'), findsOneWidget);
      expect(basketRepository.items, isEmpty);
    });
  });
}
