class Bill {
  final String id;
  final double total;
  final int split;
  final DateTime date;
  final double tipPercentage;
  final double discount;
  final double tax;
  final bool roundUp;

  Bill({
    required this.id,
    required this.total,
    required this.split,
    required this.date,
    this.tipPercentage = 15.0,
    this.discount = 0.0,
    this.tax = 0.0,
    this.roundUp = false,
  });

  // Helper getters for calculations
  double get taxAmount => (total * tax) / 100;
  double get subtotal => total + taxAmount;
  double get tipAmount => (subtotal * tipPercentage) / 100;
  double get discountedAmount =>
      (subtotal - discount).clamp(0, double.infinity);
  double get totalWithTip => discountedAmount + tipAmount;
  double get perPersonAmount {
    if (split <= 0) return totalWithTip;
    return roundUp ? totalWithTip.ceil() / split : totalWithTip / split;
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'split': split,
      'date': date.toIso8601String(),
      'tipPercentage': tipPercentage,
      'discount': discount,
      'tax': tax,
      'roundUp': roundUp,
    };
  }

  // Create from Map
  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] ?? DateTime.now().toIso8601String(),
      total: map['total']?.toDouble() ?? 0.0,
      split: map['split']?.toInt() ?? 1,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      tipPercentage: map['tipPercentage']?.toDouble() ?? 15.0,
      discount: map['discount']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      roundUp: map['roundUp'] ?? false,
    );
  }

  // Copy with method for easy updates
  Bill copyWith({
    String? id,
    double? total,
    int? split,
    DateTime? date,
    double? tipPercentage,
    double? discount,
    double? tax,
    bool? roundUp,
  }) {
    return Bill(
      id: id ?? this.id,
      total: total ?? this.total,
      split: split ?? this.split,
      date: date ?? this.date,
      tipPercentage: tipPercentage ?? this.tipPercentage,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      roundUp: roundUp ?? this.roundUp,
    );
  }
}
