import 'package:flutter/material.dart';
import '../../../../models/budget_models.dart';

class FloatingConnectCard extends StatelessWidget {
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFD8A5FF), Color(0xFFC77FE8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC77FE8).withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                                  child: const Icon(Icons.close, color: Colors.white70, size: 24),
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
                                  colors: [Color(0xFFD8A5FF), Color(0xFFC77FE8)],
                                ),
                              ),
                              child: const Icon(Icons.credit_card, color: Colors.white, size: 40),
                            ),
                          ),
                          // description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Text(
                              'Link your bank card to automatically import transactions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          // masked card number (static)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A2A3F).withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Text(
                                    '•••• •••• •••• ••••',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 14,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // connect button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD8A5FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () {
                                  onCardConnected();
                                  Navigator.pop(context);
                                  _showTransactionSwiper(context);
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check, color: Colors.white, size: 20),
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                                child: const Icon(Icons.close, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        // make the swipe area flexible and scrollable if needed
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: _SwipeDeck(
                                transactions: transactions,
                                onAction: onTransactionAction,
                                onEdit: onTransactionEdit,
                                parentContext: context, // Pass the parent context
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

// Minimal swipe deck to avoid overflow
class _SwipeDeck extends StatefulWidget {
  final List<Transaction> transactions;
  final void Function(Transaction, bool) onAction;
  final Function(Transaction)? onEdit;
  final BuildContext? parentContext;

  const _SwipeDeck({
    required this.transactions,
    required this.onAction,
    this.onEdit,
    this.parentContext,
  });

  @override
  State<_SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<_SwipeDeck> {
  int index = 0;
  double drag = 0;

  @override
  Widget build(BuildContext context) {
    if (index >= widget.transactions.length) {
      return SizedBox(
        height: 320,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFD8A5FF), size: 48),
              const SizedBox(height: 12),
              Text(
                'All transactions reviewed',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      );
    }

    final tx = widget.transactions[index];

    return SizedBox(
      height: 360,
      child: ClipRect(
        child: GestureDetector(
          onHorizontalDragUpdate: (d) {
            setState(() {
              drag = (drag + d.delta.dx).clamp(-240.0, 240.0);
            });

          },
          onHorizontalDragEnd: (_) {
            if (drag > 60) {
              // Swipe right - accept transaction
              widget.onAction(tx, true);
              setState(() {
                drag = 0;
                index++;
              });
            } else if (drag < -60) {
              // Swipe left - edit transaction
              if (widget.onEdit != null) {
                // Close the swiper dialog first, then show edit dialog
                Navigator.of(context).pop();
                // Add delay to ensure proper dialog handling
                Future.delayed(const Duration(milliseconds: 200), () {
                  widget.onEdit!(tx);
                });
              } else {
                // Fallback to old behavior
                widget.onAction(tx, false);
                setState(() {
                  drag = 0;
                  index++;
                });
              }
            } else {
              setState(() {
                drag = 0;
              });
            }
          },
          child: Stack(
            children: [
              // background cues
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Opacity(
                          opacity: drag < -20 ? ((-drag - 20) / 80).clamp(0.0, 0.3) : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3), // Blue for edit
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Opacity(
                          opacity: drag > 20 ? ((drag - 20) / 80).clamp(0.0, 0.3) : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50), // Green for accept
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // card
              Transform.translate(
                offset: Offset(drag, 0),
                child: _TransactionCard(tx: tx, position: '${index + 1}/${widget.transactions.length}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction tx;
  final String position;

  const _TransactionCard({required this.tx, required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2A3F), Color(0xFF2A3F5F)],
        ),
        border: Border.all(color: const Color(0xFFD8A5FF).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8A5FF).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD8A5FF).withValues(alpha: 0.3),
                ),
                child: const Icon(Icons.restaurant, color: Color(0xFFD8A5FF), size: 24),
              ),
              Text('Af $position', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '-${tx.amount.toStringAsFixed(2)} €',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _labelValue('MERCHANT', tx.merchant ?? 'Unknown'),
          const SizedBox(height: 12),
          _labelValue('DESCRIPTION', tx.description ?? tx.note),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD8A5FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tx.category,
              style: const TextStyle(color: Color(0xFFD8A5FF), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          _labelValue(
            'DATE',
            '${tx.date.day}/${tx.date.month}/${tx.date.year}',
          ),
        ],
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
