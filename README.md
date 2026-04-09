# ExpenseTracker

ExpenseTracker is a clean, modern Flutter app for tracking daily spending with speed and clarity.

## ✨ Highlights

- Add and manage expenses by title, amount, date, and category
- Attach optional photos from **camera** or **gallery**
- Local persistence with SQLite (your data stays on device)
- Beautiful expense chart for quick spending insight
- Undo delete with a snackbar action
- Light/Dark mode toggle
- English/Arabic localization with runtime language switching
- Optional layout flip for RTL/LTR testing and accessibility

## 🧰 Tech Stack

- **Flutter** + **Dart**
- **Riverpod** for state management
- **sqflite** for local database storage
- **easy_localization** for i18n
- **image_picker** + **flutter_image_compress** for expense photos

## 🚀 Quick Start

### 1) Prerequisites

- Flutter SDK installed
- Android Studio / Xcode (for mobile targets)
- A connected emulator/device

### 2) Install dependencies

```bash
flutter pub get
```

### 3) Run the app

```bash
flutter run
```

## ✅ Quality Checks

```bash
flutter analyze
flutter test
```

## 📁 Project Structure (high level)

```text
lib/
  core/         # config + theme
  models/       # data models
  providers/    # Riverpod providers/state
  viewmodels/   # UI state orchestration
  widgets/      # screens and reusable UI
assets/
  translations/ # en / ar strings
```

## 📌 Notes

- Expense images are stored locally in SQLite as binary BLOB data.
- Desktop SQLite support is initialized for Windows/Linux.
