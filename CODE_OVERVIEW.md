# Code Overview - Spendings App

Quick reference for understanding this Flutter personal finance app.

## Directory Structure

```
lib/
├── main.dart                              # App entry + SpendingDashboard widget
├── models/
│   ├── balance.dart                       # Balance data model
│   └── transaction.dart                   # Transaction data model
├── services/
│   ├── database_service.dart              # SQLite persistence (singleton)
│   └── csv_service.dart                   # CSV import/export
└── widgets/
    ├── balance_dialog.dart                # Dialog for setting balance
    ├── balance_header.dart                # Balance display header
    ├── transaction_form.dart              # Add/Edit form (full-screen)
    ├── transaction_list_view.dart         # Main list display with grouping
    ├── transaction_list_sheet.dart        # Bottom sheet for category details
    ├── category_pie_chart.dart            # Pie chart visualization
    ├── monthly_bar_chart.dart             # Monthly bar chart (expenses vs income)
    └── category_analysis_chart.dart       # Category spending analysis

test/
├── models/
│   ├── balance_test.dart                  # 10 tests
│   └── transaction_test.dart              # 11 tests
├── services/csv_service_test.dart         # 17 tests
└── widgets/
    ├── balance_dialog_test.dart           # 9 tests
    ├── balance_header_test.dart           # 7 tests
    ├── transaction_form_test.dart         # 5 tests
    └── transaction_list_view_test.dart    # 5 tests
```

## Data Models

### Balance (`lib/models/balance.dart`)

```dart
class Balance {
  int? id;              // Auto-increment DB ID
  double amount;        // Initial balance amount
  DateTime date;        // Effective date (transactions on/after affect balance)
  DateTime createdAt;   // When balance was set
}
```

**Key Methods:**
- `toMap()` / `fromMap()` - Database serialization
- `copyWith()` - Immutable copy with modifications

### Transaction (`lib/models/transaction.dart`)

```dart
class Transaction {
  int? id;              // Auto-increment DB ID
  DateTime date;        // Transaction date
  String category;      // Category name
  String label;         // Description
  double debit;         // Expense amount (0 if income)
  double credit;        // Income amount (0 if expense)
}
```

**Key Properties:**
- `bool get isExpense` → `debit > 0`
- `bool get isIncome` → `credit > 0`
- `double get amount` → absolute value of debit or credit

**Key Methods:**
- `toMap()` / `fromMap()` - Database serialization
- `copyWith()` - Immutable copy with modifications
- `parseDate(String, int year)` - Parses French month names (janv, fevr, mars, avr, mai, juin, juil, aout, sept, oct, nov, dec)
- `parseAmount(String)` - Parses amounts with comma decimal (e.g., "1 234,56")

## Services

### DatabaseService (`lib/services/database_service.dart`)

Singleton pattern for SQLite access.

**Database Schema (v2):**
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,           -- ISO8601 format
  category TEXT NOT NULL,
  label TEXT,
  debit REAL DEFAULT 0,
  credit REAL DEFAULT 0
)

CREATE TABLE balance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,         -- Initial balance amount
  date TEXT NOT NULL,           -- Effective date
  created_at TEXT NOT NULL      -- When balance was set
)
```

**Transaction Methods:**
| Method | Description |
|--------|-------------|
| `Future<Database> get database` | Lazy-loads database |
| `insertTransaction(Transaction)` | Returns new ID |
| `updateTransaction(Transaction)` | Returns affected rows |
| `deleteTransaction(int id)` | Returns affected rows |
| `getAllTransactions()` | Returns all, sorted by date DESC |
| `getAllCategories()` | Returns distinct category names |
| `importFromCsv(List<Transaction>)` | Batch insert |
| `isEmpty()` | Check if DB is empty |

**Balance Methods:**
| Method | Description |
|--------|-------------|
| `getBalance()` | Returns most recent Balance or null |
| `setBalance(Balance)` | Clears existing, inserts new |
| `deleteBalance()` | Removes balance tracking |
| `calculateCurrentBalance()` | Returns: initial + credits - debits (since balance date) |

**Initial Data:** Seeds 623 transactions (Jan-Dec 2025) on first run.

### CsvService (`lib/services/csv_service.dart`)

Static methods for CSV import/export.

**Format:** `Date;Category;Label;Amount`
- Date: DD/MM/YYYY
- Amount: negative for expenses, positive for income

**Key Methods:**
| Method | Description |
|--------|-------------|
| `generateCsv(List<Transaction>)` | Creates CSV string with header |
| `parseCsv(String)` | Returns `({List<Transaction>, int skipped})` |
| `parseLine(String)` | Parses single CSV line |

## Widgets

### SpendingDashboard (`lib/main.dart`)

Root stateful widget managing app state.

**State:**
- `List<Transaction>? _transactions` - Loaded transactions
- `bool _isLoading` - Loading indicator
- `String? _selectedCategory` - Category filter
- `Balance? _balance` - Current balance settings
- `double _currentBalance` - Calculated balance value

**Key Methods:**
- `_loadData()` - Fetches transactions and balance from database
- `_addTransaction()` / `_updateTransaction()` / `_deleteTransaction()` - CRUD operations
- `_importFromCsv()` - File picker → parse → batch insert
- `_exportToCsv()` - Generate CSV → temp file → native share
- `_openTransactionForm()` - Navigate to form
- `_showBalanceDialog()` - Open dialog to set/edit balance
- `_resetBalance()` - Confirmation dialog → delete balance

**UI:** AppBar with menu (Import/Export/Balance), BalanceHeader, FAB (Add), Category dropdown, TransactionListView

### TransactionListView (`lib/widgets/transaction_list_view.dart`)

Displays transactions grouped by month and category.

**Constructor:**
```dart
TransactionListView({
  required List<Transaction> transactions,
  Function(Transaction)? onEdit,
  Function(int)? onDelete,
  void Function(String? category)? onAdd,
})
```

**State:**
- `String _filter` - 'all', 'expenses', 'income'
- `String _searchQuery` - Search text
- `String _currentMonth` - Visible month for badge

**Features:**
- Search by label/category
- Filter chips (All/Expenses/Income)
- Grouped display: Month headers → Category cards
- Tap category → opens TransactionListSheet

### TransactionListSheet (`lib/widgets/transaction_list_sheet.dart`)

Bottom sheet showing transactions for a category/month.

**Features:**
- Sorting: date/amount, ascending/descending
- Each transaction shows: day number, label, amount, edit/delete buttons
- FAB for adding to selected category

### TransactionForm (`lib/widgets/transaction_form.dart`)

Full-screen form for add/edit.

**Constructor:**
```dart
TransactionForm({
  Transaction? transaction,      // null = add mode
  required List<String> categories,
  String? initialCategory,
})
```

**Fields:**
1. Date picker
2. Type toggle (Expense/Income)
3. Category (dropdown or new)
4. Label (required)
5. Amount (required, > 0)

### BalanceHeader (`lib/widgets/balance_header.dart`)

Header widget displayed below AppBar showing balance.

**Constructor:**
```dart
BalanceHeader({
  required double currentBalance,
  required Balance? balanceInfo,
  required VoidCallback onTap,
})
```

**Display:**
- No balance: "Tap to set initial balance" prompt
- With balance: Current balance (green/red), "Since [date]", edit icon

### BalanceDialog (`lib/widgets/balance_dialog.dart`)

Dialog for setting/editing balance.

**Constructor:**
```dart
BalanceDialog({Balance? existingBalance})
```

**Fields:**
1. Balance amount (required, validates as number)
2. Effective date (defaults to now, optional date picker)

### Chart Widgets

| Widget | Purpose |
|--------|---------|
| `CategoryPieChart` | Pie chart of expenses by category with legend |
| `MonthlyBarChart` | Grouped bar chart: expenses vs income per month |
| `CategoryAnalysisChart` | Line chart + stats for single category over time |

## Widget Hierarchy

```
MyApp
└── SpendingDashboard (manages all state)
    ├── AppBar (Import/Export/Balance menu)
    ├── BalanceHeader (tap → BalanceDialog)
    ├── Category dropdown filter
    └── TransactionListView
        ├── Search TextField
        ├── Filter chips
        └── Grouped ListView
            └── Category Card (tap → TransactionListSheet)
                ├── Transaction rows (edit/delete)
                └── FAB (add to category)

TransactionForm (full-screen, returned via Navigator.pop)
BalanceDialog (AlertDialog, returned via Navigator.pop)
```

## Data Flow

1. **App Launch:** `SpendingDashboard.initState()` → `_loadData()` → loads transactions + balance + calculates current balance
2. **Display:** `TransactionListView` groups by month/category, `BalanceHeader` shows current balance
3. **Add:** FAB → `TransactionForm` → `Navigator.pop(transaction)` → `DatabaseService.insertTransaction()` → `_loadData()` (balance auto-updates)
4. **Edit:** Edit button → `TransactionForm(transaction)` → `Navigator.pop(updated)` → `DatabaseService.updateTransaction()` → `_loadData()` (balance auto-updates)
5. **Delete:** Delete button → Confirm dialog → `DatabaseService.deleteTransaction()` → `_loadData()` (balance auto-updates)
6. **Import:** Menu → FilePicker → `CsvService.parseCsv()` → `DatabaseService.importFromCsv()` → `_loadData()`
7. **Export:** Menu → `CsvService.generateCsv()` → temp file → `share_plus`
8. **Set Balance:** BalanceHeader tap or Menu → `BalanceDialog` → `Navigator.pop(balance)` → `DatabaseService.setBalance()` → `_loadData()`
9. **Reset Balance:** Menu → Confirm dialog → `DatabaseService.deleteBalance()` → `_loadData()`

**Balance Calculation:** `Current = Initial Amount + Sum(Credits since date) - Sum(Debits since date)`

## Dependencies

```yaml
fl_chart: ^0.69.0         # Charts
sqflite: ^2.3.0           # SQLite
path: ^1.8.3              # Path utilities
share_plus: ^10.0.0       # Native sharing
path_provider: ^2.1.0     # Directory access
file_picker: ^8.0.0       # File selection
```

## Test Coverage

**63 tests total** (~13 seconds)

| File | Tests | Coverage |
|------|-------|----------|
| `balance_test.dart` | 10 | Serialization, copyWith, constructor |
| `transaction_test.dart` | 11 | Date parsing, amount parsing, serialization, properties |
| `csv_service_test.dart` | 17 | Generate, parse, roundtrip, edge cases |
| `balance_dialog_test.dart` | 9 | Rendering, validation, date picker |
| `balance_header_test.dart` | 7 | Display states, tap callback |
| `transaction_form_test.dart` | 4 | Rendering, validation, toggle, new category |
| `transaction_list_view_test.dart` | 5 | Display, filtering, search, callbacks |

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run app
flutter analyze          # Check for issues
flutter test             # Run all tests
flutter test test/models/transaction_test.dart  # Single file
```

## Theme Colors

- Primary: `#1E88E5` (blue)
- Secondary: `#26A69A` (teal)
- Tertiary: `#EF5350` (red - expenses)
- Surface: `#F8F9FA` (light gray)
- Income: Green
- Expenses: Red
