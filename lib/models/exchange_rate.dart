/// Model class for currency exchange rate data
/// Deserializes JSON response from the API
class ExchangeRate {
  final String baseCurrency;
  final String date;
  final Map<String, double> rates;

  ExchangeRate({
    required this.baseCurrency,
    required this.date,
    required this.rates,
  });

  /// Factory constructor for creating ExchangeRate from JSON
  /// This is the deserialization process
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      baseCurrency: json['base'] as String,
      date: json['date'] as String,
      rates: Map<String, double>.from(
        (json['rates'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
    );
  }

  /// Get rate for a specific currency
  double? getRateFor(String currency) {
    return rates[currency];
  }

  /// Convert an amount from base currency to target currency
  double convert(double amount, String targetCurrency) {
    final rate = getRateFor(targetCurrency);
    if (rate == null) return amount;
    return amount * rate;
  }
}
