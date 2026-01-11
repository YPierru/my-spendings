# My Spendings

A Flutter mobile application for personal finance tracking and expense management. Import transaction data from CSV files, visualize spending patterns with interactive charts, and manage your financial data with powerful filtering and search capabilities.

## Features

### Transaction Management
- Import transactions from CSV files with French date and number formats
- Add, edit, and delete transactions manually
- Persistent local storage using SQLite
- Support for both expenses and income tracking

### Data Visualization
- Category-based pie charts showing expense distribution
- Monthly bar charts for income vs. expenses comparison
- Category analysis charts with detailed breakdowns
- Interactive data exploration with drill-down capabilities

### Filtering and Search
- Filter transactions by category
- Search transactions by label or description
- Toggle between expenses-only and income-only views
- Sort transactions by date, amount, or category
- Group transactions by category for easier analysis

### Data Import
- Automatic CSV parsing on first launch
- Support for semicolon-delimited CSV files (Latin-1 encoding)
- French date format support (e.g., "15-janv", "03-fevr")
- French number format support (comma as decimal separator)

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

3. Prepare your CSV data file:
   - Place your CSV file at `res/data.csv`
   - CSV format: `date;category;label;debit;credit`
   - Date format: `DD-MMM` (French month abbreviations: janv, fevr, mars, etc.)
   - Number format: Use comma as decimal separator (e.g., `12,50`)

4. Run the app:
   ```bash
   flutter run
   ```

## CSV Data Format

The app expects a CSV file with the following structure:

```csv
date;category;label;debit;credit
15-janv;Groceries;Supermarket purchase;45,50;
20-janv;Salary;Monthly salary;;2500,00
```

Format specifications:
- Delimiter: semicolon (`;`)
- Encoding: Latin-1 (ISO-8859-1)
- Date format: `DD-MMM` where MMM is a French month abbreviation
- Amounts: Comma as decimal separator
- Parser stops at row containing "NE RIEN ECRIRE"

## Project Structure

```
lib/
├── main.dart                      # App entry point and dashboard
├── models/
│   └── transaction.dart           # Transaction data model
├── services/
│   ├── csv_parser.dart            # CSV import logic
│   └── database_service.dart      # SQLite persistence layer
└── widgets/
    ├── transaction_list_view.dart # Transaction list with filters
    ├── transaction_form.dart      # Add/edit transaction form
    ├── category_pie_chart.dart    # Category distribution chart
    ├── monthly_bar_chart.dart     # Monthly trends chart
    └── category_analysis_chart.dart # Detailed category analysis

res/
└── data.csv                       # Transaction data file
```

## Tech Stack

### Core Framework
- **Flutter** - Cross-platform mobile app framework
- **Dart** - Programming language

### Key Dependencies
- **sqflite** (^2.3.0) - Local SQLite database for data persistence
- **fl_chart** (^0.69.0) - Interactive charts and data visualization
- **path** (^1.8.3) - File path manipulation utilities

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
On first launch, the app automatically imports transactions from `res/data.csv` and stores them in a local SQLite database. Subsequent launches load data from the database for faster performance.

### Adding Transactions
1. Tap the floating action button (+) in the bottom-right corner
2. Fill in the transaction details (date, category, label, amount)
3. Select whether it's an expense (debit) or income (credit)
4. Tap "Save" to add the transaction

### Filtering Data
- Use the category dropdown at the top to filter by specific categories
- Use the search bar in the transaction list to find specific transactions
- Toggle between "All", "Expenses", and "Income" views
- Switch between individual and grouped display modes

### Viewing Charts
Navigate through the app to access different visualization views:
- Category distribution (pie chart)
- Monthly trends (bar chart)
- Detailed category analysis

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
