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
1. **Database Service** (`lib/services/database_service.dart`) - SQLite persistence layer (singleton pattern). Seeds initial transaction data on first run; subsequent launches use cached database. Manages transactions, balance, and accounts tables. Supports demo mode with separate `transactions_demo.db` database. Provides `insertTransactions()` batch method for efficient multi-transaction insertion
2. **Demo Data Generator** (`lib/services/demo_data_generator.dart`) - Generates realistic fake data for demonstration purposes. Creates demo accounts (Personal, Joint Account, Savings) with 50-80 randomized transactions each spanning 6 months. Includes expense categories (Groceries, Transport, Entertainment, etc.) and income categories (Salary, Freelance, Refund) with realistic labels and amount ranges
3. **CSV Service** (`lib/services/csv_service.dart`) - Handles CSV import/export with format `Date;Category;Label;Amount`. Shows non-dismissible loading dialog during operations with error handling
4. **Transaction Model** (`lib/models/transaction.dart`) - Data class with `parseDate()` for French month names and `parseAmount()` for comma decimal separator. Supports `toMap()`/`fromMap()` for database serialization
5. **Balance Model** (`lib/models/balance.dart`) - Data class storing initial balance amount and effective date. Supports `toMap()`/`fromMap()` for database serialization
6. **Account Model** (`lib/models/account.dart`) - Data class for account information with support for renaming via AccountFormDialog
7. **Dashboard** (`lib/main.dart`) - Main widget that manages account selection and displays account list. Provides CSV import/export with loading indicators and balance management via menu. Handles demo mode toggling through AccountManager
8. **List View** (`lib/widgets/transaction_list_view.dart`) - Displays transactions with three view modes: monthly grouped (default), yearly grouped, or flat list. Shows last transaction date below filter chips. Categories are sorted alphabetically (case-insensitive). Supports mode switching via FilterChips. Tapping a category opens a bottom sheet showing all transactions for that category in the selected time period. Flat view allows direct transaction interaction

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
- **Database Methods** (account-specific):
  - `getBalanceForAccount(int accountId)` - Retrieves the stored balance for an account
  - `setBalanceForAccount(Balance)` - Saves or updates the balance (replaces existing)
  - `deleteBalanceForAccount(int accountId)` - Removes balance tracking for an account
  - `calculateCurrentBalanceForAccount(int accountId)` - Computes current balance from initial amount and transactions
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

##### View Modes
Transactions can be displayed in three different view modes, selectable via FilterChips below the expense/income filter:

1. **Monthly Grouped** (default) - Transactions grouped by month, then by category
   - Shows month headers (e.g., "January 2026")
   - Categories sorted alphabetically (case-insensitive) within each month
   - Scroll badge displays current month when scrolling
   - Tapping a category card opens a bottom sheet showing all transactions for that category in that month

2. **Yearly Grouped** - Transactions grouped by year, then by category
   - Shows year headers (e.g., "2026")
   - Categories sorted alphabetically (case-insensitive) within each year
   - Scroll badge displays current year when scrolling
   - Tapping a category card opens a bottom sheet showing all transactions for that category in that year

3. **Flat List** - Ungrouped chronological list of all transactions
   - Displays most recent transactions first
   - Each transaction shows: date, category, label, and amount
   - No scroll badge displayed
   - Tapping a transaction opens a bottom sheet with Edit and Delete actions

**View Mode UI Elements:**
- Three FilterChip buttons with icons: Calendar (Month), Calendar Range (Year), List (Flat)
- Selected mode is highlighted visually
- Switching modes automatically scrolls view to top and resets scroll badge
- Mode preference persists during the session but resets on app restart

**Transaction Display (Bottom Sheet):**
- Calendar icon with the day number
- Transaction label (or category name if no label exists)
- Amount (color-coded: red for expenses, green for income)
- Edit and delete action buttons

##### Adding Transactions
- **Multi-Transaction Entry** (primary flow):
  - The floating action button (+) opens `MultiTransactionForm` for batch entry
  - Uses a single entry form + staged transactions table pattern
  - **Entry form**: date picker + category dropdown on same row, label with autocomplete, expense/income toggle + amount + "Add" button
  - User fills the form and taps **"Add"** to stage a transaction; the form clears completely for the next entry
  - **Staged table**: compact rows showing date, category, label, amount (color-coded), and delete (✕) button
  - **Short tap** on a staged row loads it into the form for editing (button changes to "Update", row highlighted)
  - "Use same date for all" — applies retroactively to all already-staged transactions when toggled on or when shared date changes
  - **Save All (N)** button appears only when staged transactions exist; saves all via batch insert (`insertTransactions` method)
  - When adding from a category context (bottom sheet), that category is pre-selected for convenience
  - Form validation ensures label and amount are provided before adding to staging

##### Editing Transactions
- **Single Transaction Form** (editing only):
  - Tapping edit button on an existing transaction opens `TransactionForm`
  - Full-screen form with category selection or creation
  - Used exclusively for editing; all new transaction entry uses `MultiTransactionForm`

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
- `TransactionListView` (stateful) - Displays transactions with three view modes (monthly grouped, yearly grouped, flat list) selectable via FilterChips. Supports search and expense/income filtering. Includes scroll badge showing current month/year (hidden in flat view). Accepts `onEdit`, `onDelete`, and `onAdd` callbacks for transaction management. Uses `ViewMode` enum with values: `monthlyGrouped`, `yearlyGrouped`, `flat`. Automatically scrolls to top when switching modes
- `TransactionListSheet` (stateful) - Bottom sheet displaying transactions for a category with sorting options (date/amount, ascending/descending)
- `MultiTransactionForm` (stateful) - Primary form for adding new transactions. Uses single entry form + staged transactions table pattern:
  - Single entry form with date+category row, label autocomplete, type toggle + amount + "Add"/"Update" button
  - Staged transactions table showing compact rows (date, category, label, amount, delete button)
  - Short tap on staged row loads it into form for editing (button changes to "Update", row highlighted blue)
  - "Use same date for all" applies retroactively to all staged transactions
  - "Save All (N)" button only visible when staged transactions exist, triggers batch insert
  - Accepts `initialCategory` for pre-selecting category when adding from category context
  - Returns `List<Transaction>` when submitted successfully
- `TransactionForm` (stateful) - Full-screen form for editing existing transactions. Supports category selection or creation. No longer used for adding new transactions (replaced by `MultiTransactionForm`)
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
- **Models** (`test/models/`) - Transaction, Account, and Balance model tests including French date parsing, amount parsing, serialization
- **Services** (`test/services/csv_service_test.dart`) - CSV generation, parsing, roundtrip export/import
- **Widgets** (`test/widgets/`) - TransactionForm, TransactionListView, BalanceHeader, BalanceDialog, AccountFormDialog, AccountListScreen, DeleteAccountDialog
