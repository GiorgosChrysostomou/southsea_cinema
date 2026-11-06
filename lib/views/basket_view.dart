
import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() => _BasketViewState();
}

class _BasketViewState extends State<BasketView> {
  @override
  Widget build(BuildContext context) {
    final items = basketRepository.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Basket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: items.isEmpty
            ? const Center(
                child: Text(
                  'Your basket is empty',
                  style: TextStyle(
                    color: cinemaFontWhite,
                    fontSize: 18,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Tickets',
                    style: TextStyle(
                      color: cinemaFontWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Card(
                          color: cinemaSurface,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              item.movie.title,
                              style: const TextStyle(
                                color: cinemaFontWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${item.quantity} ticket(s) x '
                              '${item.movie.formattedPrice}\n'
                              'Total: £${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: cinemaFontMuted,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: cinemaBrand,
                              ),
                              onPressed: () {
                                setState(() {
                                  basketRepository.removeTicket(
                                    item.movie,
                                    quantity: item.quantity,
                                  );
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(color: cinemaFontMuted),

                  Text(
                    'Total: £${basketRepository.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: cinemaFontWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  PrimaryButton(
                    label: 'CLEAR BASKET',
                    onPressed: () {
                      setState(() {
                        basketRepository.clearBasket();
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  PrimaryButton(
                    label: 'CHECKOUT',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Checkout coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
