import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';

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

  testWidgets('Basket displays movie and total', (WidgetTester tester) async {
    basketRepository.addTicket(movie, quantity: 2);

    await tester.pumpWidget(
      const MaterialApp(
        home: BasketView(),
      ),
    );

    expect(find.text('The Batman'), findsOneWidget);
    expect(find.textContaining('2 ticket(s)'), findsOneWidget);
    expect(find.text('Total: £20.00'), findsOneWidget);
  });

  testWidgets('Basket displays empty message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BasketView(),
      ),
    );

    expect(find.text('Your basket is empty'), findsOneWidget);
  });

  testWidgets('Delete button removes tickets', (WidgetTester tester) async {
    basketRepository.addTicket(movie, quantity: 2);

    await tester.pumpWidget(
      const MaterialApp(
        home: BasketView(),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    expect(find.text('Your basket is empty'), findsOneWidget);
  });

  testWidgets('Clear basket button removes all tickets',
      (WidgetTester tester) async {
    basketRepository.addTicket(movie, quantity: 2);

    await tester.pumpWidget(
      const MaterialApp(
        home: BasketView(),
      ),
    );

    await tester.tap(find.text('CLEAR BASKET'));
    await tester.pump();

    expect(find.text('Your basket is empty'), findsOneWidget);
  });
}
