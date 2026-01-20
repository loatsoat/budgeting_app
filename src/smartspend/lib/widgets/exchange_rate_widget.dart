import 'package:flutter/material.dart';
import '../models/exchange_rate.dart';
import '../services/exchange_rate_service.dart';

/// Widget that displays exchange rates using FutureBuilder
///
/// Best practices implemented:
/// 1. Uses FutureBuilder for async data display
/// 2. API call is NOT in build() method - stored in a Future field
/// 3. Proper loading, error, and success states
/// 4. Clean separation of concerns
class ExchangeRateWidget extends StatefulWidget {
  const ExchangeRateWidget({super.key});

  @override
  State<ExchangeRateWidget> createState() => _ExchangeRateWidgetState();
}

class _ExchangeRateWidgetState extends State<ExchangeRateWidget> {
  // Store the Future OUTSIDE build method - BEST PRACTICE
  late Future<ExchangeRate> _exchangeRateFuture;

  // Popular currencies to display
  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸'},
    {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'flag': '🇯🇵'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'flag': '🇨🇭'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the Future ONCE in initState - NOT in build()
    _exchangeRateFuture = ExchangeRateService.fetchLatestRates();
  }

  /// Refresh the exchange rates
  void _refreshRates() {
    setState(() {
      _exchangeRateFuture = ExchangeRateService.fetchLatestRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1A2030),
        border: Border.all(
          color: const Color(0xFF0D47A1).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.currency_exchange,
                        color: Color(0xFF0D47A1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exchange Rates',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Live from API',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _refreshRates,
                  icon: const Icon(Icons.refresh, color: Color(0xFF0D47A1)),
                  tooltip: 'Refresh rates',
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // FutureBuilder - PROPER WAY to display async data
          FutureBuilder<ExchangeRate>(
            future: _exchangeRateFuture,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF0D47A1),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Fetching live rates...',
                          style: TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // Error state
              else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading rates',
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.error.toString(),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refreshRates,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B8DEF),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              // Success state - data available
              else if (snapshot.hasData) {
                final exchangeRate = snapshot.data!;

                return Column(
                  children: [
                    // Date info
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Base: EUR • Updated: ${exchangeRate.date}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Currency rates list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currencies.length,
                      itemBuilder: (context, index) {
                        final currency = _currencies[index];
                        final rate = exchangeRate.getRateFor(currency['code']!);

                        return ListTile(
                          leading: Text(
                            currency['flag']!,
                            style: const TextStyle(fontSize: 28),
                          ),
                          title: Text(
                            currency['code']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            currency['name']!,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            rate != null
                                ? '€1 = ${rate.toStringAsFixed(4)}'
                                : 'N/A',
                            style: const TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              // Fallback state
              else {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No data available',
                    style: TextStyle(color: Colors.white60),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
