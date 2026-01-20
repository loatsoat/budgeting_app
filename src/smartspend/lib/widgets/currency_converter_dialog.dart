import 'package:flutter/material.dart';
import '../models/exchange_rate.dart';
import '../services/exchange_rate_service.dart';

/// Dialog that shows budget/money converted to different currencies
/// Uses FutureBuilder with external API data
class CurrencyConverterDialog extends StatefulWidget {
  final double amount;
  final String title;

  const CurrencyConverterDialog({
    super.key,
    required this.amount,
    this.title = 'Your Budget',
  });

  @override
  State<CurrencyConverterDialog> createState() =>
      _CurrencyConverterDialogState();
}

class _CurrencyConverterDialogState extends State<CurrencyConverterDialog> {
  // Store Future outside build() - BEST PRACTICE
  late Future<ExchangeRate> _exchangeRateFuture;

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸'},
    {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'flag': '🇯🇵'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'flag': '🇨🇭'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'flag': '🇨🇦'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'flag': '🇦🇺'},
  ];

  @override
  void initState() {
    super.initState();
    _exchangeRateFuture = ExchangeRateService.fetchLatestRates();
  }

  void _refreshRates() {
    setState(() {
      _exchangeRateFuture = ExchangeRateService.fetchLatestRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF1A2030),
          border: Border.all(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.currency_exchange,
                      color: Color(0xFF0D47A1),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '€${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF0D47A1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshRates,
                    icon: const Icon(Icons.refresh, color: Color(0xFF0D47A1)),
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // FutureBuilder with exchange rates
            Flexible(
              child: FutureBuilder<ExchangeRate>(
                future: _exchangeRateFuture,
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    );
                  }
                  // Error state
                  else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading rates',
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check your internet connection',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _refreshRates,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B8DEF),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  // Success state
                  else if (snapshot.hasData) {
                    final exchangeRate = snapshot.data!;

                    return Column(
                      children: [
                        // Date info
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.update,
                                color: Colors.white60,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Updated: ${exchangeRate.date}',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Currency list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _currencies.length,
                            itemBuilder: (context, index) {
                              final currency = _currencies[index];
                              final rate = exchangeRate.getRateFor(
                                currency['code']!,
                              );
                              final convertedAmount = rate != null
                                  ? exchangeRate.convert(
                                      widget.amount,
                                      currency['code']!,
                                    )
                                  : null;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0D47A1,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        currency['flag']!,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    currency['code']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currency['name']!,
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (rate != null)
                                        Text(
                                          '€1 = ${rate.toStringAsFixed(4)}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: convertedAmount != null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${currency['code']!} ${convertedAmount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Color(0xFF0D47A1),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Text(
                                              'converted',
                                              style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'N/A',
                                          style: TextStyle(
                                            color: Colors.white38,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  // Fallback
                  return const Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.white60),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
