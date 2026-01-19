# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "Spendings" - a Flutter mobile app for personal finance tracking. It persists transaction data to SQLite and displays spending/income with filtering and search capabilities.

### App Branding
- **App Name**: "Spendings" (configured in `AndroidManifest.xml` and iOS `Info.plist`)
- **App Icon**: Financial-themed icon featuring a wallet with bar chart on a blue background with gold coin accent
- **Icon Generation**: Uses `flutter_launcher_icons` package. Run `flutter pub run flutter_launcher_icons` to regenerate icons from `assets/icon/app_icon.png`

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/models/transaction_test.dart
```

## Architecture

### Data Flow
1. **Database Service** (`lib/services/database_service.dart`) - SQLite persistence layer (singleton pattern). Seeds initial transaction data on first run; subsequent launches use cached database. Manages transactions, balance, and accounts tables. Supports demo mode with separate `transactions_demo.db` database
2. **Demo Data Generator** (`lib/services/demo_data_generator.dart`) - Generates realistic fake data for demonstration purposes. Creates demo accounts (Personal, Joint Account, Savings) with 50-80 randomized transactions each spanning 6 months. Includes expense categories (Groceries, Transport, Entertainment, etc.) and income categories (Salary, Freelance, Refund) with realistic labels and amount ranges
3. **CSV Service** (`lib/services/csv_service.csv`) - Handles CSV import/export with format `Date;Category;Label;Amount`. Shows non-dismissible loading dialog during operations with error handling
4. **Transaction Model** (`lib/models/transaction.dart`) - Data class with `parseDate()` for French month names and `parseAmount()` for comma decimal separator. Supports `toMap()`/`fromMap()` for database serialization
5. **Balance Model** (`lib/models/balance.dart`) - Data class storing initial balance amount and effective date. Supports `toMap()`/`fromMap()` for database serialization
6. **Account Model** (`lib/models/account.dart`) - Data class for account information with support for renaming via AccountFormDialog
7. **Dashboard** (`lib/main.dart`) - Main widget that manages account selection and displays account list. Provides CSV import/export with loading indicators and balance management via menu. Handles demo mode toggling through AccountManager
8. **List View** (`lib/widgets/transaction_list_view.dart`) - Displays transactions grouped by category within each month. Shows last transaction date below filter chips. Categories are sorted alphabetically (case-insensitive). Tapping a category opens a bottom sheet with all transactions for that category

### Key Implementation Details
- Transactions can be either expenses (debit > 0) or income (credit > 0)
- Initial transaction data is seeded into the database on first run via `_seedInitialData()`
- Uses `sqflite` package for persistence and `fl_chart` for visualizations
- CSV operations:
  - Export uses `share_plus` for native Android/iOS share functionality
  - Import uses `file_picker` for file selection
  - Both operations display a non-dismissible loading dialog (`PopScope` with `canPop: false`) with CircularProgressIndicator
  - Dialog shows "Importing CSV..." or "Exporting CSV..." message during operation
  - Error handling displays user-friendly SnackBar messages on failure

### Demo Mode
The app includes a demo mode feature that allows users to showcase the app without revealing real financial data:
- **Separate Database**: Demo mode uses `transactions_demo.db` while real data uses `transactions.db`. Both databases persist independently
- **Database Service Methods**:
  - `isDemoMode` getter - Returns whether demo mode is currently active
  - `switchToDemoMode(bool enabled)` - Switches between demo and real mode by closing the current database connection and opening the appropriate database. Returns `true` when complete
- **Demo Data Generation**: When demo mode is activated, the system automatically generates:
  - 3 demo accounts: Personal, Joint Account, and Savings
  - 50-80 randomized transactions per account spanning the last 6 months
  - Expense categories: Groceries, Transport, Entertainment, Restaurants, Shopping, Utilities, Subscriptions (with realistic labels and amount ranges)
  - Income categories: Salary, Freelance, Refund (with realistic labels and amount ranges)
  - 85% expenses and 15% income for realistic distribution
  - Balance information with initial amounts between 1000-10000 and effective date set 6 months ago
- **UI Integration**:
  - Menu toggle in AccountListScreen: "Demo Mode" to enter, "Exit Demo Mode" to leave
  - "DEMO" badge displayed in AppBar title when demo mode is active (orange background with white text)
  - All changes made in demo mode are isolated to the demo database

### Balance Tracking
The app supports optional balance tracking with the following features:
- **Balance Model**: Stores an initial amount and effective date
- **Balance Calculation**: Current balance is calculated using the formula:
  ```
  Current Balance = Initial Amount + Sum(Credits) - Sum(Debits)
  ```
  Only transactions on or after the balance's effective date are included in the calculation
- **Database Methods**:
  - `getBalance()` - Retrieves the stored balance (single row table)
  - `setBalance(Balance)` - Saves or updates the balance (replaces existing)
  - `deleteBalance()` - Removes balance tracking
  - `calculateCurrentBalance()` - Computes current balance from initial amount and transactions
- **Auto-update**: Balance recalculates automatically when transactions are added, edited, or deleted
- **UI Integration**:
  - `BalanceHeader` widget displays below the AppBar when a balance is set
  - Shows current balance with color-coding (green for positive, red for negative)
  - When no balance is set, shows nothing (hidden)
  - Not clickable - balance can only be modified via menu
- **Menu Options**:
  - "Set Balance..." - Opens dialog to set/modify the balance (always shown with same label regardless of whether balance exists)

### UI/UX Flow

#### Account Management
- **Account List Screen**:
  - Displays accounts as large, prominent cards with enhanced visual hierarchy
  - Account name shown in 18px bold font
  - Balance displayed in 22px bold font with color-coding (green for positive, red for negative)
  - Chevron icon (→) indicates cards are tappable
  - **Tap**: Opens the account to view transactions
  - **Long Press**: Shows bottom sheet with account options:
    - "Rename" - Opens dialog to rename the account
    - "Delete" - Deletes the account (with confirmation)
  - Edit/delete buttons removed from card face for cleaner UI

#### Transaction Management
- Transactions are always displayed grouped by category (no toggle between detail and grouped views)
- Categories within each month are sorted alphabetically
- Tapping a category card opens a bottom sheet showing all transactions for that category in that month
- Each transaction in the bottom sheet displays:
  - Calendar icon with the day number
  - Transaction label (or category name if no label exists)
  - Amount (color-coded: red for expenses, green for income)
  - Edit and delete action buttons
- The floating action button (+) appears in the bottom sheet, allowing users to add new transactions to the selected category

### Widget Structure
- `SpendingDashboard` (stateful) - Root widget managing data loading, global filters, and balance state
- `AccountListScreen` (stateless) - Displays list of accounts with enhanced card design:
  - Large, prominent account cards with account name (18px bold) and balance (22px bold)
  - Balance color-coded (green for positive, red for negative)
  - Chevron icon indicates tappable cards
  - Long-press gesture shows bottom sheet with "Rename" and "Delete" options
  - Shows "DEMO" badge in AppBar when demo mode is active
  - Provides menu toggle for switching between demo and real mode
- `AccountFormDialog` (stateful) - Dialog for creating or renaming accounts
- `DeleteAccountDialog` (stateless) - Confirmation dialog for account deletion
- `BalanceHeader` (stateless) - Displays current balance below AppBar when balance is set. Shows balance amount (color-coded). Hidden when no balance exists. Not clickable
- `BalanceDialog` (stateful) - Dialog for setting/editing balance with amount input and date picker. Validates numeric input and supports comma/dot decimal separators
- `TransactionListView` (stateful) - Displays grouped transactions by month and category with search and expense/income filtering. Accepts `onEdit`, `onDelete`, and `onAdd` callbacks for transaction management
- `TransactionListSheet` (stateful) - Bottom sheet displaying transactions for a category with sorting options (date/amount, ascending/descending)
- `TransactionForm` - Full-screen form for adding/editing transactions with category selection or creation
- Chart widgets (`category_pie_chart.dart`, `monthly_bar_chart.dart`, `category_analysis_chart.dart`) - Visualizations using fl_chart

## Testing

Lightweight test suite (38 tests) focused on core functionality:

```bash
# Run all tests (~7 seconds)
flutter test

# Run specific test file
flutter test test/models/transaction_test.dart
```

### Test Coverage
- **Transaction Model** (`test/models/transaction_test.dart`) - French date parsing, amount parsing, serialization, properties
- **CSV Service** (`test/services/csv_service_test.dart`) - CSV generation, parsing, roundtrip export/import
- **TransactionForm** (`test/widgets/transaction_form_test.dart`) - Form rendering, validation, expense/income toggle, category creation
- **TransactionListView** (`test/widgets/transaction_list_view_test.dart`) - List rendering, filtering, search, bottom sheet, callbacks
