import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

void main() {
  group('Home page', () {
    testWidgets('shows the app title in the app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());

      expect(find.text('Southsea Cinema'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows a card for each movie', (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());

      expect(find.byType(MovieCard), findsNWidgets(2));
      expect(find.text('Dracula (1931) (PG)'), findsOneWidget);
      expect(find.text('Halloween (1978) (18)'), findsOneWidget);
    });

    testWidgets('shows a booking button on each card',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());

      expect(find.text('BOOK TICKETS'), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });
  });

  group('Movie listing', () {
    testWidgets('drawer opens the listing with the film details',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Movie Listing'));
      await tester.pumpAndSettle();

      expect(find.byType(MovieListing), findsOneWidget);
      expect(find.text('DRACULA (1931) (PG)'), findsOneWidget);
      expect(find.text('Adult (£7.50)'), findsOneWidget);
      expect(find.text('ADD TO ORDER'), findsOneWidget);
    });

    testWidgets('ADD TO ORDER shows feedback for the chosen quantity',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Movie Listing'));
      await tester.pumpAndSettle();

      expect(find.text('Added 2 tickets'), findsNothing);

      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'ADD TO ORDER'));
      await tester.pump();

      expect(find.text('Added 2 tickets'), findsOneWidget);
    });
  });
}
