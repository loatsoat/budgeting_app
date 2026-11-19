import 'package:flutter/material.dart';
import '../../../../models/budget_models.dart';

// Minimal swipe deck to avoid overflow
class SwipeDeck extends StatefulWidget {
  final List<Transaction> transactions;
  final void Function(Transaction, bool) onAction;
  final Function(Transaction)? onEdit;
  final BuildContext? parentContext;

  const SwipeDeck({
    super.key,
    required this.transactions,
    required this.onAction,
    this.onEdit,
    this.parentContext,
  });

  @override
  State<SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck> {
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
              const Icon(
                Icons.check_circle,
                color: Color(0xFFD8A5FF),
                size: 48,
              ),
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
                          opacity: drag < -20
                              ? ((-drag - 20) / 80).clamp(0.0, 0.3)
                              : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1), // Blue for edit
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
                          opacity: drag > 20
                              ? ((drag - 20) / 80).clamp(0.0, 0.3)
                              : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4CAF50,
                              ), // Green for accept
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
                child: _TransactionCard(
                  tx: tx,
                  position: '${index + 1}/${widget.transactions.length}',
                ),
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
                child: const Icon(
                  Icons.restaurant,
                  color: Color(0xFFD8A5FF),
                  size: 24,
                ),
              ),
              Text(
                'Af $position',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '-${tx.amount.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
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
              style: const TextStyle(
                color: Color(0xFFD8A5FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
