# SmartSpend Design System

## Overview
This design system ensures SmartSpend maintains a **calm, trustworthy, and user-friendly** interface that helps users manage their finances without visual overwhelm.

---

## Design Principles

1. **Clarity First** - Information hierarchy is more important than decoration
2. **Consistent Status Colors** - Green/Orange/Red always mean the same thing
3. **One Primary Accent** - Avoid mixing multiple bright colors
4. **Dark Background** - Calmer for finance apps, easier on the eyes
5. **Trust Through Simplicity** - Clean design builds confidence

---

## Color Palette

### Primary Accent
```dart
Color(0xFF00A8E8) // Calm, trustworthy blue
```
**Usage:** Main buttons, key highlights, primary actions
- Currency converter button
- Main CTA buttons
- Important interactive elements

### Background Colors
```dart
Color(0xFF0A0E1A) // Deep navy - Main background
Color(0xFF1A1F3A) // Card background
Color(0xFF2A3B5C) // Elevated cards (secondary info)
```

### Text Colors
```dart
Color(0xFFFFFFFF)       // Primary text (100%)
Color(0xB3FFFFFF)       // Secondary text (70%)
Color(0x99FFFFFF)       // Tertiary text (60%)
Color(0x66FFFFFF)       // Muted text (40%)
```

### Status Colors (Semantic)
```dart
Color(0xFF4CAF50) // 🟢 Green - Positive, under budget, income
Color(0xFFFF9800) // 🟡 Orange - Warning, close to limit (80-100%)
Color(0xFFE57373) // 🔴 Red - Negative, over budget, expenses
```

**Status Color Rules:**
- **Green** when budget usage < 80%
- **Orange** when budget usage 80-100%
- **Red** when budget usage > 100%

---

## Component Styling

### Cards

#### Primary Card (Wallet Summary)
```dart
Container(
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Color(0xFF2A3B5C).withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.1),
    ),
  ),
)
```
**Visual Hierarchy:** Most prominent - main financial info

#### Secondary Card (Weekly Insights, Goals)
```dart
Container(
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Color(0xFF2A3B5C), // Same color, no alpha
    borderRadius: BorderRadius.circular(20),
  ),
)
```
**Visual Hierarchy:** Calmer than primary - supporting information

### Progress Bars

```dart
Widget _buildProgressBar(double spentPercentage) {
  final percentage = spentPercentage * 100;
  
  return Container(
    decoration: BoxDecoration(
      color: percentage > 100
          ? Color(0xFFE57373)  // Red
          : percentage > 80
          ? Color(0xFFFF9800)  // Orange
          : Color(0xFF4CAF50), // Green
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
```

### Buttons

#### Primary Action Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF1A1F3A),
    elevation: 2,
  ),
  child: Text('Primary Action'),
)
```
**Example:** "View My Weekly Wrap"

#### Secondary Action Button
```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFF00A8E8),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF00A8E8).withValues(alpha: 0.15),
        blurRadius: 6,
      ),
    ],
  ),
)
```
**Example:** "View All Transactions"

---

## Typography

### Hierarchy
```dart
// Large amounts / primary focus
fontSize: 28, fontWeight: FontWeight.w700

// Section headers
fontSize: 20, fontWeight: FontWeight.bold

// Labels
fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2

// Body text
fontSize: 16, fontWeight: FontWeight.w500
```

---

## Status Indicators

### Financial Amount Display
```dart
Widget buildAmountText(double amount) {
  return Text(
    '€${amount.abs().toStringAsFixed(0)}',
    style: TextStyle(
      color: amount < 0 
          ? Color(0xFFE57373)  // Red for negative
          : Color(0xFF4CAF50), // Green for positive
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
  );
}
```

### Budget Status Labels
```dart
Widget buildStatusLabel(double leftToSpend) {
  return Text(
    leftToSpend < 0 ? 'budget exceeded' : 'left to spend',
    style: TextStyle(
      color: leftToSpend < 0 
          ? Color(0xFFE57373)  // Red
          : Colors.white,      // White
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
  );
}
```

---

## Helper Methods (in AppTheme)

### Get Status Color by Percentage
```dart
static Color getStatusColor(double percentage) {
  if (percentage > 100) return statusDanger;  // Red
  if (percentage > 80) return statusWarning;   // Orange
  return statusSuccess;                        // Green
}
```

### Get Color by Amount
```dart
static Color getAmountColor(double amount) {
  if (amount < 0) return statusDanger;   // Red
  if (amount > 0) return statusSuccess;  // Green
  return textSecondary;                  // Neutral
}
```

---

## Do's and Don'ts

### ✅ DO
- Use `Color(0xFF00A8E8)` for all primary accent needs
- Use semantic status colors consistently
- Keep secondary cards calmer than primary wallet card
- Use sufficient contrast for text (minimum 60% opacity)
- Show status through color (green/orange/red)

### ❌ DON'T
- Mix multiple bright accent colors (cyan, purple, pink) in one view
- Use gradients on secondary cards
- Make everything bright - use visual hierarchy
- Use inconsistent status colors
- Apply strong shadows/glows everywhere

---

## Accessibility

### Contrast Ratios
- Primary text on dark background: 18:1 (WCAG AAA)
- Secondary text (70%): 12.6:1 (WCAG AAA)
- Status colors tested for color-blind users

### Color-Blind Considerations
- Green/Red status is also indicated by text labels
- Icons supplement color information
- Percentage values provide numeric feedback

---

## Migration Guide

Replace these colors gradually:

```dart
// OLD → NEW
Color(0xFF00F5FF) → Color(0xFF00A8E8)  // Cyan to calm blue
Color(0xFF00FF88) → Color(0xFF4CAF50)  // Bright green to semantic green
Colors.red → Color(0xFFE57373)         // Bright red to muted red
```

---

## Example: Complete Wallet Card

```dart
Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: const Color(0xFF2A3B5C).withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.1),
    ),
  ),
  child: Column(
    children: [
      // Header
      Text(
        'PERSONAL WALLET',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Main amount with status color
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '€1,234 ',
              style: TextStyle(
                color: Color(0xFF4CAF50), // Green = positive
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: 'left to spend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
      
      // Status bar
      Container(
        decoration: BoxDecoration(
          color: Color(0xFF4CAF50), // Green = under budget
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Income / Expenses
      Row(
        children: [
          _buildIndicator('INCOME', '€2,500', Color(0xFF4CAF50)),
          _buildIndicator('EXPENSES', '€1,266', Color(0xFFE57373)),
        ],
      ),
    ],
  ),
)
```

---

## Questions?

For design decisions or new component patterns, refer to these principles:
1. Does it reduce visual noise?
2. Is the status immediately clear?
3. Does it use consistent colors?
4. Is it accessible?
5. Does it build trust?

---

**Version:** 1.0  
**Last Updated:** January 2026  
**Maintained by:** SmartSpend Design Team
