# Spendings

A Flutter mobile application for personal finance tracking and expense management. Manage transactions with import/export capabilities, visualize spending patterns, and filter your financial data with powerful search and filtering features.

## Features

### Transaction Management
- Add, edit, and delete transactions manually
- Persistent local storage using SQLite
- Support for both expenses and income tracking
- Comes with sample data to get started quickly

### CSV Import/Export
- Import transactions from CSV files via file picker
- Export transactions to CSV and share via email, messaging apps, etc.
- CSV format: `Date;Category;Label;Amount` (semicolon-delimited)
- Supports both dot and comma as decimal separators

### Filtering and Search
- Filter transactions by category
- Search transactions by label or description
- Toggle between expenses-only and income-only views
- View transactions grouped by category within each month
- Categories are sorted alphabetically (case-insensitive)

## Getting Started

### Prerequisites
- Flutter SDK 3.10.4 or higher
- Dart SDK (included with Flutter)
- Android Studio / Xcode for mobile development
- A device or emulator for testing

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd test_dummy
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## CSV Data Format

The app uses the following CSV structure for import/export:

```csv
Date;Category;Label;Amount
15/03/2025;Groceries;Supermarket purchase;-45.50
25/01/2025;Salary;Monthly salary;4500.00
```

Format specifications:
- Delimiter: semicolon (`;`)
- Date format: `DD/MM/YYYY`
- Amount: negative for expenses, positive for income
- Supports both dot (`.`) and comma (`,`) as decimal separator when importing

## Project Structure

```
lib/
├── main.dart                      # App entry point and dashboard
├── models/
│   └── transaction.dart           # Transaction data model
├── services/
│   ├── csv_service.dart           # CSV import/export logic
│   └── database_service.dart      # SQLite persistence layer
└── widgets/
    ├── transaction_list_view.dart # Transaction list with filters
    ├── transaction_form.dart      # Add/edit transaction form
    ├── category_pie_chart.dart    # Category distribution chart
    ├── monthly_bar_chart.dart     # Monthly trends chart
    └── category_analysis_chart.dart # Detailed category analysis
```

## Tech Stack

### Core Framework
- **Flutter** - Cross-platform mobile app framework
- **Dart** - Programming language

### Key Dependencies
- **sqflite** (^2.3.0) - Local SQLite database for data persistence
- **fl_chart** (^0.69.0) - Chart visualizations
- **share_plus** (^10.0.0) - Native share functionality for CSV export
- **path_provider** (^2.1.0) - Temporary file storage
- **file_picker** (^8.0.0) - File selection for CSV import

### Architecture Patterns
- Singleton pattern for database service
- Stateful widgets for reactive UI
- Service layer for business logic separation
- Model classes for data serialization

## Development

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Code Analysis
```bash
# Analyze code for issues
flutter analyze
```

### Building for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Usage

### First Launch
On first launch, the app seeds sample transaction data into the SQLite database. This gives you a realistic dataset to explore the app's features.

### Viewing Transactions
Transactions are displayed grouped by category within each month. Categories are sorted alphabetically (case-insensitive). Each category card shows:
- Category name
- Total amount (expenses in red, income in green)
- Number of transactions

### Viewing Category Details
1. Tap on any category card to open a detailed view in a bottom sheet
2. The bottom sheet displays all transactions for that category in that month
3. Each transaction shows:
   - Calendar icon with the day number
   - Transaction label (or category name if no label exists)
   - Amount (color-coded: red for expenses, green for income)
   - Edit and delete buttons for transaction management

### Adding Transactions
1. Tap on a category card to open the bottom sheet
2. Tap the floating action button (+) inside the bottom sheet
3. Fill in the transaction details (date, category, label, amount)
4. Select whether it's an expense (debit) or income (credit)
5. Tap "Save" to add the transaction

### Editing and Deleting Transactions
1. Open a category's bottom sheet by tapping the category card
2. Find the transaction you want to modify
3. Tap the edit button (pencil icon) to modify transaction details
4. Tap the delete button (trash icon) to remove the transaction

### Filtering Data
- Use the category dropdown at the top to filter by specific categories
- Use the search bar in the transaction list to find specific transactions
- Toggle between "All", "Expenses", and "Income" views to focus on specific transaction types

### Importing CSV
1. Tap the menu icon (three dots) in the app bar
2. Select "Import CSV..."
3. Choose a CSV file from your device
4. Transactions will be added to your existing data

### Exporting CSV
1. Tap the menu icon (three dots) in the app bar
2. Select "Export CSV..."
3. Choose how to share the file (email, messaging apps, save to files, etc.)

## Contributing

Contributions are welcome! Please follow these guidelines:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## License

This project is a personal finance tracking application. License details to be added.

## Support

For questions, issues, or feature requests, please open an issue in the repository.
