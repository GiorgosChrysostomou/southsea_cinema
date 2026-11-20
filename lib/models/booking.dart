class Booking {
  final int? id;
  final String bookingNumber;
  final String summary;
  final double total;
  final DateTime date;

  Booking({
    this.id,
    required this.bookingNumber,
    required this.summary,
    required this.total,
    required this.date,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int?,
      bookingNumber: map['bookingNumber'] as String,
      summary: map['summary'] as String,
      total: (map['total'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingNumber': bookingNumber,
      'summary': summary,
      'total': total,
      'date': date.toIso8601String(),
    };
  }

  String get formattedTotal => '£${total.toStringAsFixed(2)}';
}
