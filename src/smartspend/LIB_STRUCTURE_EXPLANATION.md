# Flutter App Structure 

## Project Overview
**SmartSpend Budget Tracking App** is built with Flutter. It features authentication, budget management, transaction tracking.

---

## 📂 File Structure & Explanations

### **Root Files**

#### `lib/main.dart`
**Purpose:** Application entry point
- Initializes the Flutter app
- Sets up light/dark theme support with `AppTheme`
- Configures the home screen to use `BudgetApp`
- Enables system theme mode detection

---

### **📊 Models** 

#### `lib/models/budget_models.dart`
**Purpose:** Data models for the budget app
**Contains:**
- `Transaction` - Transaction data model with type, amount, category, date
- `TransactionType` enum - expense, income, transfer
- `CategoryData` - Category configuration with colors, icons, subcategories
- `SubcategoryBudget` - Budget tracking for subcategories
- `defaultCategories` - Predefined categories (Housing, Food, Savings, Income)

---

### **Main Budget App**

#### `lib/screens/screens/budget/app_budget.dart`
**Purpose:** Main budget tracking screen (REFACTORED - Now much cleaner!)
**Features:**
- **Transaction Management:** Add, view, and categorize expenses/income
- **Budget Tracking:** Set budgets per category and subcategory
- **Visual Budget Display:** Circular progress chart showing budget usage
- **Animated UI:** Smooth transitions and glassmorphic design
- **Tab Navigation:** Overview and Budget tabs

**Now uses modular widgets from:**
- `widgets/budget_header.dart` - Status bar and header
- `widgets/circular_budget_chart.dart` - Budget visualization
- `widgets/category_card.dart` - Category display cards
- `widgets/bottom_navigation.dart` - Tab navigation
- `widgets/budget_animated_background.dart` - Animated background

---

### **🎨 Budget Widgets** (NEW - Extracted for better organization!)

#### `lib/screens/screens/budget/widgets/budget_header.dart`
**Components:**
- `BudgetStatusBar` - Shows time, date, and battery status
- `BudgetHeader` - App title with settings and edit buttons

#### `lib/screens/screens/budget/widgets/circular_budget_chart.dart`
**Component:** `CircularBudgetChart`
- Displays circular progress indicator for budget usage
- Shows budget left, total budget, and spent amount
- Color-coded based on usage percentage

#### `lib/screens/screens/budget/widgets/category_card.dart`
**Component:** `CategoryCard`
- Expandable category cards with icon and gradient
- Shows total spent vs budgeted
- Displays subcategories when expanded
- Edit mode support

#### `lib/screens/screens/budget/widgets/bottom_navigation.dart`
**Component:** `BudgetBottomNavigation`
- Tab navigation between Overview and Budget
- Animated gradient effects
- Active tab highlighting

#### `lib/screens/screens/budget/widgets/budget_animated_background.dart`
**Component:** `BudgetAnimatedBackground`
- Rotating gradient orbs
- Smooth animations for visual depth

---

### **🎨 Themes**

#### `lib/themes/app_theme.dart`
**Purpose:** Centralized theme configuration
**Features:**
- Light theme with white backgrounds
- Dark theme with dark backgrounds
- Consistent color palette across the app
- Material 3 design system
- Custom text styles for all typography
- Styled input fields, buttons, and cards

**Color Scheme:**
- Primary: `#030213` (dark blue)
- Accent: `#395587` (blue)
- Destructive: `#D4183D` (red)
- Borders and backgrounds with proper opacity

---

### **🔐 Authentication**

#### `lib/data/services/auth_service.dart`
**Purpose:** Mock authentication service (singleton pattern)
**Methods:**
- `login(email, password)` - Validates and logs in user
- `signup(name, email, password)` - Creates new account
- `resetPassword(email)` - Sends password reset
- `logout()` - Clears authentication state

**Note:** This is a mock implementation. In production, connect to a real backend API.

---

### **📱 Screens**

#### `lib/screens/screens/auth/auth_screen.dart`
**Purpose:** Authentication flow coordinator
- Manages switching between login, signup, and forgot password screens
- Uses `AnimatedSwitcher` for smooth transitions
- Includes animated background

#### `lib/screens/screens/auth/login_screen.dart`
**Purpose:** User login interface
**Features:**
- Email and password input fields
- Form validation
- Password visibility toggle
- Animated logo with pulsing effect
- Links to signup and forgot password
- Loading state during authentication

#### `lib/screens/screens/auth/signup_screen.dart`
**Purpose:** New user registration
**Features:**
- Username, email, and password fields
- Password confirmation
- Form validation (min 6 characters)
- Back to login navigation
- Loading state

#### `lib/screens/screens/auth/forgot_password_screen.dart`
**Purpose:** Password reset flow
**Features:**
- Email input for reset link
- Success/error feedback
- Auto-redirect to login after success

#### `lib/screens/screens/home/home_screen.dart`
**Purpose:** Main app home screen (placeholder)
**Features:**
- Two tabs: Overview and Budget
- Animated background
- Bottom navigation with gradient effects
- Settings button
- Placeholder content (full features in `app_budget.dart`)

---

### **🎨 Reusable Widgets**

#### `lib/widgets/widgets/animated_background.dart`
**Purpose:** Animated lava lamp background effect
**How it works:**
- Creates 5 animated gradient orbs
- Uses `CustomPainter` for rendering
- Continuous rotation and movement
- Adds depth and visual interest to screens

#### `lib/widgets/widgets/custom_text_field.dart`
**Purpose:** Styled text input component
**Features:**
- Label and hint text
- Prefix icon support
- Optional suffix icon (e.g., password visibility toggle)
- Form validation support
- Glassmorphic styling
- Keyboard type configuration

#### `lib/widgets/widgets/glassmorphic_card.dart`
**Purpose:** Frosted glass effect container
**Features:**
- Backdrop blur filter
- Gradient background
- Border and shadow effects
- Configurable border radius and padding
- Creates modern, depth-filled UI

#### `lib/widgets/widgets/gradient_button.dart`
**Purpose:** Styled gradient button
**Features:**
- Blue gradient background
- Glow shadow effect
- Ripple touch feedback
- Configurable height and border radius
- Disabled state support

---

## 🎯 Key Features Summary

### ✅ Authentication System
- Login, signup, and password reset flows
- Form validation
- Mock authentication service (ready for backend integration)

### ✅ Budget Management
- Category-based budgeting
- Subcategory tracking
- Visual budget progress
- Edit mode for budget adjustments

### ✅ Transaction Tracking
- Add income/expenses
- Categorize transactions
- Transaction history
- Date-based organization

### ✅ Modern UI/UX
- Glassmorphic design
- Animated backgrounds
- Smooth transitions
- Dark/light theme support
- Gradient accents and glows

---

## 🔧 Technical Details

### State Management
- Uses `StatefulWidget` with `setState()`
- Animation controllers for smooth effects
- Form state management with `GlobalKey<FormState>`

### Design Patterns
- Singleton pattern for `AuthService`
- Model classes for data structures
- Reusable widget components
- Separation of concerns (screens, widgets, services, themes)

### Dependencies Used
- `flutter/material.dart` - Material Design widgets
- `dart:math` - Mathematical calculations for animations
- `dart:ui` - Backdrop filter for glassmorphic effects

---

## 🚀 Next Steps for Development

1. **Backend Integration:** Replace mock `AuthService` with real API calls
2. **Database:** Add local storage (SQLite/Hive) or cloud database (Firebase)
3. **Transaction CRUD:** Complete add/edit/delete transaction functionality
4. **Analytics:** Add spending insights and charts
5. **Notifications:** Budget alerts and reminders
6. **Export:** PDF/CSV export of transactions
7. **Multi-currency:** Support for different currencies

---

## ✨ All Errors Fixed!

All deprecated `.withValues()` calls have been replaced with `.withValues(alpha: ...)` for Flutter 3.27+ compatibility.
