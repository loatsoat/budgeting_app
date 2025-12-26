import 'package:flutter/material.dart';

class CustomTabs extends StatefulWidget {
  final List<TabItem> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final EdgeInsetsGeometry? padding;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;

  const CustomTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
    this.padding,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
  });

  @override
  State<CustomTabs> createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        widget.onChanged?.call(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: widget.padding ?? const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: widget.tabs.map((tab) => Tab(
              text: tab.label,
              icon: tab.icon,
            )).toList(),
            indicator: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(9),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: widget.labelColor ?? theme.colorScheme.onSurface,
            unselectedLabelColor: widget.unselectedLabelColor ?? 
                theme.colorScheme.onSurface.withValues(alpha: 0.6),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: theme.textTheme.bodyMedium,
            dividerColor: Colors.transparent,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs.map((tab) => tab.content).toList(),
          ),
        ),
      ],
    );
  }
}

class TabItem {
  final String label;
  final Widget content;
  final Widget? icon;

  const TabItem({
    required this.label,
    required this.content,
    this.icon,
  });
}

class SimpleTabs extends StatelessWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const SimpleTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == selectedIndex;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged?.call(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected 
                            ? theme.primaryColor 
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (tab.icon != null) ...[
                        IconTheme(
                          data: IconThemeData(
                            color: isSelected 
                                ? theme.primaryColor 
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          child: tab.icon!,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        tab.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected 
                              ? theme.primaryColor 
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: isSelected 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        tabs[selectedIndex].content,
      ],
    );
  }
}