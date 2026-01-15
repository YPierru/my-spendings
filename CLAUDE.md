# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "Spendings" - a Flutter mobile app for personal finance tracking. It persists transaction data to SQLite and displays spending/income with filtering and search capabilities.

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
1. **Database Service** (`lib/services/database_service.dart`) - SQLite persistence layer (singleton pattern). Seeds initial transaction data on first run; subsequent launches use cached database. Manages both transactions and balance tables
2. **CSV Service** (`lib/services/csv_service.dart`) - Handles CSV import/export with format `Date;Category;Label;Amount`
3. **Transaction Model** (`lib/models/transaction.dart`) - Data class with `parseDate()` for French month names and `parseAmount()` for comma decimal separator. Supports `toMap()`/`fromMap()` for database serialization
4. **Balance Model** (`lib/models/balance.dart`) - Data class storing initial balance amount and effective date. Supports `toMap()`/`fromMap()` for database serialization
5. **Dashboard** (`lib/main.dart`) - Main widget that loads transactions and balance, provides category filtering, CSV import/export, and balance management via menu
6. **List View** (`lib/widgets/transaction_list_view.dart`) - Displays transactions grouped by category within each month. Categories are sorted alphabetically (case-insensitive). Tapping a category opens a bottom sheet with all transactions for that category

### Key Implementation Details
- Transactions can be either expenses (debit > 0) or income (credit > 0)
- Initial transaction data is seeded into the database on first run via `_seedInitialData()`
- Uses `sqflite` package for persistence and `fl_chart` for visualizations
- CSV export uses `share_plus` for native Android/iOS share functionality
- CSV import uses `file_picker` for file selection

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
