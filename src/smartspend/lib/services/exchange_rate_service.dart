import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_rate.dart';

/// Service class for fetching exchange rates from external API
/// Following best practices:
/// 1. Uses http package for HTTP requests
/// 2. Returns Future for async operations
/// 3. Proper error handling
/// 4. JSON deserialization to custom data structure
class ExchangeRateService {
  // Using frankfurter.app - a free, open-source API for currency exchange rates
  // No API key required
  static const String _baseUrl = 'https://api.frankfurter.app';

  /// Fetch latest exchange rates for EUR
  /// Returns a Future<ExchangeRate> - proper async pattern
  /// 
  /// This method should NEVER be called in a build() method
  /// Use FutureBuilder widget instead
  static Future<ExchangeRate> fetchLatestRates() async {
    try {
      // Make HTTP GET request
      final response = await http.get(
        Uri.parse('$_baseUrl/latest?from=EUR'),
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Deserialize JSON to ExchangeRate object
        return ExchangeRate.fromJson(jsonData);
      } else {
        throw Exception('Failed to load exchange rates. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rates: $e');
    }
  }

  /// Fetch exchange rates for specific currencies
  static Future<ExchangeRate> fetchRatesForCurrencies(List<String> currencies) async {
    try {
      final currencyParams = currencies.join(',');
      final response = await http.get(
        Uri.parse('$_baseUrl/latest?from=EUR&to=$currencyParams'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ExchangeRate.fromJson(jsonData);
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rates: $e');
    }
  }

  /// Fetch historical rates for a specific date
  static Future<ExchangeRate> fetchHistoricalRates(DateTime date) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await http.get(
        Uri.parse('$_baseUrl/$dateString?from=EUR'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ExchangeRate.fromJson(jsonData);
      } else {
        throw Exception('Failed to load historical rates');
      }
    } catch (e) {
      throw Exception('Error fetching historical rates: $e');
    }
  }
}
