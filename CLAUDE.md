# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "My Spendings" - a Flutter mobile app for personal finance tracking. It parses transaction data from a CSV file, persists to SQLite, and displays spending/income with filtering and search capabilities.

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
1. **CSV Parser** (`lib/services/csv_parser.dart`) - Loads and parses `res/data.csv` (semicolon-delimited, Latin-1 encoded) containing transaction data with French date formats (e.g., "15-janv")
2. **Database Service** (`lib/services/database_service.dart`) - SQLite persistence layer (singleton pattern). On first run, imports CSV data; subsequent launches use cached database
3. **Transaction Model** (`lib/models/transaction.dart`) - Data class with `parseDate()` for French month names and `parseAmount()` for comma decimal separator. Supports `toMap()`/`fromMap()` for database serialization
4. **Dashboard** (`lib/main.dart`) - Main widget that loads transactions and provides category filtering
5. **List View** (`lib/widgets/transaction_list_view.dart`) - Displays transactions grouped by category within each month. Categories are sorted alphabetically. Tapping a category opens a bottom sheet with all transactions for that category

### Key Implementation Details
- CSV uses semicolon delimiter with columns: date, category, label, debit, credit
- French month abbreviations are normalized (accents removed) before parsing: janv→1, fevr→2, mars→3, avr→4, mai→5, juin→6, juil→7, aout→8, sept→9, oct→10, nov→11, dec→12
- Transactions can be either expenses (debit > 0) or income (credit > 0)
- CSV parsing stops at "NE RIEN ECRIRE" marker row
- Uses `sqflite` package for persistence and `fl_chart` for visualizations

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
- `SpendingDashboard` (stateful) - Root widget managing data loading and global filters
- `TransactionListView` (stateful) - Displays grouped transactions by month and category with search and expense/income filtering. Accepts `onEdit`, `onDelete`, and `onAdd` callbacks for transaction management
- `TransactionListSheet` (stateful) - Bottom sheet displaying transactions for a category with sorting options (date/amount, ascending/descending)
- `TransactionForm` - Full-screen form for adding/editing transactions with category selection or creation
- Chart widgets (`category_pie_chart.dart`, `monthly_bar_chart.dart`, `category_analysis_chart.dart`) - Visualizations using fl_chart

## Testing

Lightweight test suite (28 tests) focused on core functionality:

```bash
# Run all tests (~7 seconds)
flutter test

# Run specific test file
flutter test test/models/transaction_test.dart
```

### Test Coverage
- **Transaction Model** (`test/models/transaction_test.dart`) - French date parsing, amount parsing, serialization, properties
- **CSV Parser** (`test/services/csv_parser_test.dart`) - Aggregation functions: getExpensesByCategory, getBalanceByCategory, getMonthlyTotals, getTotalExpenses, getTotalIncome
- **TransactionForm** (`test/widgets/transaction_form_test.dart`) - Form rendering, validation, expense/income toggle, category creation
- **TransactionListView** (`test/widgets/transaction_list_view_test.dart`) - List rendering, filtering, search, bottom sheet, callbacks
