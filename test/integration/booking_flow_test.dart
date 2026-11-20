import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/home_view.dart';

import '../helpers/fake_cinema_database.dart';

// Hands HomeView films that were already read from movies.json.
class LoadedMovieRepository extends MovieRepository {
  final List<Movie> movies;

  LoadedMovieRepository(this.movies);

  @override
  Future<List<Movie>> loadMoviesFromAsset([
    String path = 'assets/data/movies.json',
  ]) {
    return Future.value(movies);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    basketRepository.clearBasket();
  });

  group('Booking flow with films from the JSON asset', () {
    test('add, remove and checkout work on repository level', () async {
      final List<Movie> movies = await MovieRepository().loadMoviesFromAsset();
      final Movie dracula = movies[0];
      final Movie halloween = movies[1];

      basketRepository.addTicket(dracula, quantity: 3);
      basketRepository.addTicket(halloween, quantity: 1);

      expect(basketRepository.totalTickets, 4);
      expect(basketRepository.total, 30.0);

      basketRepository.removeTicket(dracula, quantity: 1);

      expect(basketRepository.totalTickets, 3);
      expect(basketRepository.total, 22.5);

      basketRepository.clearBasket();

      expect(basketRepository.items, isEmpty);
      expect(basketRepository.totalTickets, 0);
    });

    testWidgets('add tickets, remove one film and check out',
        (WidgetTester tester) async {
      final FakeCinemaDatabase database = FakeCinemaDatabase();

      // Read the real movies.json (real file I/O, so outside the fake clock).
      final List<Movie> movies = (await tester.runAsync(
        () => MovieRepository().loadMoviesFromAsset(),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: HomeView(repository: LoadedMovieRepository(movies)),
          routes: {
            '/basket': (context) => BasketView(database: database),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Add 2 tickets for the first film.
      await tester.tap(find.text('BOOK TICKETS').at(0));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2').last);
      await tester.pumpAndSettle();
      final Finder addButton1 =
          find.widgetWithText(ElevatedButton, 'ADD TO ORDER');
      await tester.ensureVisible(addButton1);
      await tester.pumpAndSettle();
      await tester.tap(addButton1);
      await tester.pump();

      expect(
          find.text('Added 2 tickets for ${movies[0].title}'), findsOneWidget);
      expect(basketRepository.totalTickets, 2);

      // Back to the home page, then add 1 ticket for the second film.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.text('BOOK TICKETS').at(1));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1').last);
      await tester.pumpAndSettle();
      final Finder addButton2 =
          find.widgetWithText(ElevatedButton, 'ADD TO ORDER');
      await tester.ensureVisible(addButton2);
      await tester.pumpAndSettle();
      await tester.tap(addButton2);
      await tester.pump();

      expect(basketRepository.totalTickets, 3);
      expect(basketRepository.total, 22.5);

      // Back to the home page and open the basket from the drawer.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Basket'));
      await tester.pumpAndSettle();

      expect(find.text(movies[0].title), findsOneWidget);
      expect(find.text(movies[1].title), findsOneWidget);
      expect(find.text('Total: £22.50'), findsOneWidget);

      // Remove the first film from the basket.
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      expect(find.text(movies[0].title), findsNothing);
      expect(find.text(movies[1].title), findsOneWidget);
      expect(basketRepository.totalTickets, 1);
      expect(find.text('Total: £7.50'), findsOneWidget);

      // Checkout saves a numbered booking, then empties the basket.
      await tester.ensureVisible(find.text('CHECKOUT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CHECKOUT'));
      await tester.pumpAndSettle();

      expect(find.text('Booking SC-0001 confirmed'), findsOneWidget);
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(basketRepository.items, isEmpty);
      expect(basketRepository.total, 0.0);

      expect(database.saved.length, 1);
      expect(database.saved.first.summary, '1 x ${movies[1].title}');
      expect(database.saved.first.total, 7.5);
    });
  });
}
