# Debt Tracker App

A modern Flutter application for tracking and managing your debts with a beautiful dark theme interface.

## Features

- 📱 Modern dark theme UI with blue accents
- 💰 Track multiple debts with detailed information
- 📊 Visual progress tracking with percentage indicators
- 📅 Record payments with dates and notes
- 🔍 Filter and sort debts
- 📈 Track payment history
- 🗑️ Delete debts and payments
- 💾 Persistent data storage using SQLite

## Screenshots

[![[2025-03-27-13-08-03.mp4]]]

## Project Structure

```
lib/
├── models/          # Data models (Debt, Payment)
├── providers/       # State management (DebtProvider, PaymentProvider)
├── screens/         # App screens
├── services/        # Database and other services
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

## Features in Detail

### Debt Management

- Create new debts with name, description, and total amount
- Track payment progress with visual indicators
- View detailed debt information
- Delete debts with confirmation

### Payment Tracking

- Add payments with amount, date, and optional notes
- View payment history for each debt
- Delete individual payments
- Automatic progress calculation

### Data Persistence

- All data is stored locally using SQLite
- Data persists between app launches
- Automatic backup and recovery

## Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- SQLite for data persistence
