import 'package:flutter/material.dart';

class OverviewListScreen extends StatefulWidget {
  const OverviewListScreen({super.key});

  @override
  State<OverviewListScreen> createState() => _OverviewListScreenState();
}

class _OverviewListScreenState extends State<OverviewListScreen> {
  final String _currentMonth = 'November 2025';
  final int _transactionCount = 0;
  // Mock lists with header + content
  final List<Map<String, dynamic>> _lists = [
    {
      'title': 'Groceries',
      'subtitle': '5 items',
      'content': ['Milk - \$3.50', 'Bread - \$2.00', 'Eggs - \$4.00'],
    },
    {
      'title': 'Transport',
      'subtitle': '2 items',
      'content': ['Taxi - \$12.00', 'Bus - \$1.50'],
    },
    {
      'title': 'Subscriptions',
      'subtitle': '1 item',
      'content': ['Music - \$9.99'],
    },
  ];

  // Track expanded/collapsed state per list (true = show content)
  final Map<int, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A3F5F),
              Color(0xFF1A1F33),
              Color(0xFF0A0E1A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildStatusBar(),
                _buildHeader(),
                _buildTabSelector(),
                const SizedBox(height: 24),
                _buildMonthSelector(),
                const SizedBox(height: 24),
                _buildTransactionsList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '23:34 Tuesday 4 Nov.',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              const Text('100%', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F5FF),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Personal Wallet',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3F5F).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00F5FF), Color(0xFF00D4FF)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0xFF00F5FF).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: const Center(
            child: Text('LIST', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3F5F).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00F5FF).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _roundIconButton(Icons.chevron_left, const Color(0xFF00F5FF)),
          Column(
            children: [
              Text(
                _currentMonth,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$_transactionCount TRANSACTIONS',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFFF6B9D), shape: BoxShape.circle)),
                ],
              ),
            ],
          ),
          _roundIconButton(Icons.chevron_right, const Color(0xFF00F5FF)),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F33).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Show only the list headers by default; tap toggles content visibility
          for (var i = 0; i < _lists.length; i++) ...[
            InkWell(
              onTap: () {
                setState(() {
                  _expanded[i] = !(_expanded[i] ?? false);
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lists[i]['title'],
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _lists[i]['subtitle'],
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                        ),
                      ],
                    ),
                    Icon(
                      _expanded[i] == true ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
            // Content area, shown only when expanded
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in _lists[i]['content'] as List<String>)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(entry, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14)),
                      ),
                  ],
                ),
              ),
              crossFadeState: (_expanded[i] == true) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            const Divider(color: Color(0xFF2A3F5F), height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF3D8F)]),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF6B9D).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1F33).withValues(alpha: 0.95),
            const Color(0xFF0A0E1A).withValues(alpha: 0.98),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF00F5FF), Color(0xFF00D4FF)]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.visibility, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text('Overview', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.calendar_month, color: Colors.white70, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text('Budget', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
