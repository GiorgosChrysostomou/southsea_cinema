import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

// A repository that returns the films without reading any file.
// If a completer is given, the films only arrive when the test completes it.
class FakeMovieRepository extends MovieRepository {
  final Completer<List<Movie>>? completer;

  FakeMovieRepository({this.completer});

  @override
  Future<List<Movie>> loadMoviesFromAsset([
    String path = 'assets/data/movies.json',
  ]) {
    if (completer != null) {
      return completer!.future;
    }
    return Future.value(getMovies());
  }
}

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
  group('Home page', () {
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
  });

  group('Movie listing', () {
    testWidgets('BOOK TICKETS opens the listing with the film details',
        (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('BOOK TICKETS').first);
      await tester.pumpAndSettle();

      expect(find.byType(MovieListing), findsOneWidget);
      expect(find.text('Dracula (1931) (PG)'), findsOneWidget);
      expect(find.text('Adult (£7.50)'), findsOneWidget);
      expect(find.text('ADD TO ORDER'), findsOneWidget);
    });

    testWidgets('ADD TO ORDER shows feedback for the chosen quantity',
        (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('BOOK TICKETS').first);
      await tester.pumpAndSettle();

      expect(find.text('Added 2 tickets for Dracula (1931)'), findsNothing);

      await tester.ensureVisible(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2').last);
      await tester.pumpAndSettle();

      final Finder addButton =
          find.widgetWithText(ElevatedButton, 'ADD TO ORDER');
      await tester.ensureVisible(addButton);
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pump();

      expect(find.text('Added 2 tickets for Dracula (1931)'), findsOneWidget);
    });
  });
}