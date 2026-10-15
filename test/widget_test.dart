import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
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
}