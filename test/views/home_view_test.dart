import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

import '../helpers/fake_movie_repository.dart';

Widget buildApp(MovieRepository repository) {
  return MaterialApp(
    home: HomeView(repository: repository),
  );
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(buildApp(FakeMovieRepository()));
  await tester.pumpAndSettle();
}

void main() {
  group('HomeView', () {
    testWidgets('shows the app title in the app bar',
        (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.text('Southsea Cinema'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows a loading indicator before the films load',
        (WidgetTester tester) async {
      final Completer<List<Movie>> completer = Completer<List<Movie>>();

      await tester.pumpWidget(
        buildApp(FakeMovieRepository(completer: completer)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MovieCard), findsNothing);

      completer.complete(MovieRepository().getMovies());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(MovieCard), findsNWidgets(2));
    });

    testWidgets('shows a card for each movie', (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.byType(MovieCard), findsNWidgets(2));
      expect(find.text('Dracula (1931) (PG)'), findsOneWidget);
      expect(find.text('Halloween (1978) (18)'), findsOneWidget);
    });

    testWidgets('shows a booking button on each card',
        (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.text('BOOK TICKETS'), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('BOOK TICKETS opens the movie listing',
        (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('BOOK TICKETS').first);
      await tester.pumpAndSettle();

      expect(find.byType(MovieListing), findsOneWidget);
      expect(find.text('Dracula (1931) (PG)'), findsOneWidget);
    });

    testWidgets('shows an error message when loading fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(FailingMovieRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Could not load films'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(MovieCard), findsNothing);
    });
  });
}
