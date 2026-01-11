# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "My Spendings" - a Flutter mobile app for personal finance tracking. It parses transaction data from a CSV file, persists to SQLite, and displays spending/income with filtering, search, and chart visualizations.

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
flutter test test/widget_test.dart
```

## Architecture

### Data Flow
1. **CSV Parser** (`lib/services/csv_parser.dart`) - Loads and parses `res/data.csv` (semicolon-delimited, Latin-1 encoded) containing transaction data with French date formats (e.g., "15-janv")
2. **Database Service** (`lib/services/database_service.dart`) - SQLite persistence layer (singleton pattern). On first run, imports CSV data; subsequent launches use cached database
3. **Transaction Model** (`lib/models/transaction.dart`) - Data class with `parseDate()` for French month names and `parseAmount()` for comma decimal separator. Supports `toMap()`/`fromMap()` for database serialization
4. **Dashboard** (`lib/main.dart`) - Main widget that loads transactions and provides category filtering
5. **List View** (`lib/widgets/transaction_list_view.dart`) - Displays transactions with search, expense/income filter, grouping by category, and sorting options

### Key Implementation Details
- CSV uses semicolon delimiter with columns: date, category, label, debit, credit
- French month abbreviations are normalized (accents removed) before parsing: janv→1, fevr→2, mars→3, avr→4, mai→5, juin→6, juil→7, aout→8, sept→9, oct→10, nov→11, dec→12
- Transactions can be either expenses (debit > 0) or income (credit > 0)
- CSV parsing stops at "NE RIEN ECRIRE" marker row
- Uses `fl_chart` package for visualizations and `sqflite` for persistence

### Widget Structure
- `SpendingDashboard` (stateful) - Root widget managing data loading and global filters
- `TransactionListView` (stateful) - Local filtering, search, grouping toggle, and sort controls
- `TransactionForm` - Modal for adding/editing transactions with category autocomplete
- Chart widgets in `lib/widgets/` - `CategoryPieChart`, `MonthlyBarChart`, `CategoryAnalysisChart`
