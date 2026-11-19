import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/budget_models.dart';
import 'swipe_deck.dart';

class FloatingConnectCard extends StatefulWidget {
  final List<Transaction> transactions;
  final VoidCallback onCardConnected;
  final Function(Transaction, bool) onTransactionAction;
  final Function(Transaction)? onTransactionEdit;

  const FloatingConnectCard({
    super.key,
    required this.transactions,
    required this.onCardConnected,
    required this.onTransactionAction,
    this.onTransactionEdit,
  });

  @override
  State<FloatingConnectCard> createState() => _FloatingConnectCardState();
}

class _FloatingConnectCardState extends State<FloatingConnectCard> {
  final TextEditingController _cardNumberController = TextEditingController();
  final FocusNode _cardNumberFocus = FocusNode();
  bool _isCardNumberValid = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNumberFocus.dispose();
    super.dispose();
  }

  void _formatCardNumber(String value) {
    String formatted = '';
    int count = 0;

    // Remove all non-digits
    String digits = value.replaceAll(RegExp(r'\D'), '');

    // Take only first 16 digits
    digits = digits.substring(0, math.min(16, digits.length));

    // Add space every 4 digits
    for (int i = 0; i < digits.length; i++) {
      if (count > 0 && count % 4 == 0) {
        formatted += ' ';
      }
      formatted += digits[i];
      count++;
    }

    setState(() {
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      _isCardNumberValid = digits.length == 16;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 24, bottom: 100),
        child: GestureDetector(
          onTap: () => _showConnectCardDialog(context),
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF5B8DEF),
            ),
            child: const Icon(Icons.credit_card, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  void _showConnectCardDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SafeArea(
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 420,
                  // keep within screen height with margin
                  maxHeight: constraints.maxHeight - 48,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A3F5F), Color(0xFF1A2A3F)],
                      ),
                      border: Border.all(
                        color: const Color(0xFFD8A5FF).withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // header
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 24),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'Connect Your Card',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // icon
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFD8A5FF),
                                    Color(0xFFC77FE8),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.credit_card,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          // description
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Text(
                              'Link your bank card to automatically import transactions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          // card number input field
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CARD NUMBER',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2A3B5C,
                                    ).withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isCardNumberValid
                                          ? const Color(0xFFD8A5FF)
                                          : Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _cardNumberController,
                                    focusNode: _cardNumberFocus,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      letterSpacing: 2,
                                    ),
                                    keyboardType: TextInputType.number,
                                    maxLength: 19, // 16 digits + 3 spaces
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      filled: false,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      hintText: '1234 5678 9012 3456',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        fontSize: 14,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    onChanged: _formatCardNumber,
                                  ),
                                ),
                                if (!_isCardNumberValid &&
                                    _cardNumberController.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Please enter a valid 16-digit card number',
                                      style: TextStyle(
                                        color: Colors.red.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // connect button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5B8DEF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () {
                                  if (_isCardNumberValid) {
                                    widget.onCardConnected();
                                    Navigator.pop(context);
                                    _showTransactionSwiper(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a valid 16-digit card number',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'CONNECT CARD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showTransactionSwiper(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => SafeArea(
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 440,
                  maxHeight: constraints.maxHeight - 48,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A3F5F), Color(0xFF1A2A3F)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 24),
                              const Text(
                                'Review Transactions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(dialogContext),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // make the swipe area flexible and scrollable if needed
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: SwipeDeck(
                                transactions: widget.transactions,
                                onAction: widget.onTransactionAction,
                                onEdit: widget.onTransactionEdit,
                                parentContext:
                                    context, // Pass the parent context
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Swipe left to edit • Swipe right to accept',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
