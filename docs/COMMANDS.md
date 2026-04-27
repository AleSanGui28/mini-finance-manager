# Important Commands Reference

This document contains all important commands for the Mini Finance Manager Flutter app development workflow.

---

## Table of Contents

1. [Flutter Commands](#flutter-commands)
2. [Dart Commands](#dart-commands)
3. [Build Runner Commands](#build-runner-commands)
4. [Database Commands](#database-commands)
5. [Development & Debugging](#development--debugging)
6. [Clean & Reset](#clean--reset)

---

## Flutter Commands

### `flutter run -d windows`

**Context:** Launch the Flutter app on Windows desktop

**What it does:**

- Builds the app in debug mode
- Starts the app on Windows
- Enables hot reload and DevTools
- Prints Flutter service URLs for debugging

**Example:**

```bash
cd c:\Users\asanc\mini_finance_manager
flutter run -d windows
```

**Output:**

```
Launching lib\main.dart on Windows in debug mode...
Building Windows application...                    XX.Xs
√ Built build\windows\x64\runner\Debug\mini_finance_manager.exe
Syncing files to device Windows...

Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

---

### `flutter run -d chrome`

**Context:** Launch the Flutter app on Chrome (for web testing)

**What it does:**

- Compiles Dart to JavaScript
- Launches the app in Chrome browser
- Enables web debugging

**Example:**

```bash
flutter run -d chrome
```

**Requirements:** Chrome browser installed

---

### `flutter pub get`

**Context:** Install or update dependencies

**What it does:**

- Downloads all dependencies from pubspec.yaml
- Updates the .dart_tool folder
- Resolves version conflicts
- Creates pubspec.lock file

**Example:**

```bash
flutter pub get
```

**When to use:** After modifying pubspec.yaml or after pulling code changes

---

### `flutter pub upgrade`

**Context:** Upgrade dependencies to latest compatible versions

**What it does:**

- Checks for newer versions of all packages
- Updates to the latest version within version constraints
- Updates pubspec.lock

**Example:**

```bash
flutter pub upgrade
```

**When to use:** Periodically to keep dependencies up to date

---

### `flutter pub outdated`

**Context:** Check which packages have newer versions available

**What it does:**

- Lists all packages with available updates
- Shows current version and latest available version
- Indicates if upgrades are breaking changes

**Example:**

```bash
flutter pub outdated
```

**Sample Output:**

```
Package Name            Current  Upgradable  Resolvable  Latest
drift                   2.18.0   2.18.1      2.18.1      2.19.0
uuid                    4.0.0    4.1.0       4.1.0       4.2.0
path_provider           2.1.0    2.1.1       2.1.1       2.2.0
```

---

### `flutter devices`

**Context:** List available devices for running the app

**What it does:**

- Shows all connected devices/emulators
- Displays device type and status
- Used with `flutter run -d [device]`

**Example:**

```bash
flutter devices
```

**Sample Output:**

```
2 connected devices:

Windows (desktop) • windows • windows-x64  • Microsoft Windows [Version 10.0.22631]
Chrome (web)      • chrome  • web-javascript • Google Chrome 123.0.6312.122
```

---

### `flutter clean`

**Context:** Remove all build artifacts and rebuild from scratch

**What it does:**

- Deletes build/ folder
- Clears compiled outputs
- Resets build cache
- Frees up disk space

**Example:**

```bash
flutter clean
```

**When to use:**

- After major dependency changes
- When experiencing strange build errors
- Before committing to version control

---

## Dart Commands

### `dart run build_runner build`

**Context:** Generate code from annotations (Drift database, etc.)

**What it does:**

- Scans Dart files for code generation annotations
- Runs generators (drift_dev, etc.)
- Creates .g.dart files with generated code
- Non-incremental - rebuilds everything

**Example:**

```bash
cd c:\Users\asanc\mini_finance_manager
dart run build_runner build
```

**Output:**

```
Built build_runner:build_runner.
XXs drift_dev on 48 inputs: 12 skipped, 24 output, 12 no-op; spent 7s sdk, 5s analyzing, 2s resolving
Xs source_gen:combining_builder on 24 inputs: 12 skipped, 1 output, 11 no-op

Built with build_runner/aot in XXs; wrote 25 outputs.
```

**Generated Files:**

- `lib/core/database/app_database.g.dart` - Drift database implementation
- Other .g.dart files from future generators

---

### `dart run build_runner watch`

**Context:** Continuously watch for code changes and regenerate

**What it does:**

- Monitors .dart files for changes
- Automatically reruns generators when files change
- Keeps .g.dart files in sync
- Incremental - only regenerates affected files

**Example:**

```bash
dart run build_runner watch
```

**Output:**

```
Loading source assets...
[INFO] Generating build script...
[INFO] Generating build script completed, took XXXms

[INFO] Building new asset graph completed, took XXs

[INFO] Checking for updates since last build...
[INFO] Running build...
[INFO] Building target completed, took XXs
```

**When to use:** During active development when frequently modifying database schema

---

### `dart run build_runner clean`

**Context:** Remove all generated files

**What it does:**

- Deletes all .g.dart files
- Cleans build cache for generators
- Useful before committing or sharing code

**Example:**

```bash
dart run build_runner clean
```

---

### `dart format lib/`

**Context:** Format Dart code according to conventions

**What it does:**

- Applies Dart style guide formatting
- Fixes indentation, spacing, line breaks
- Makes code consistent across the project

**Example:**

```bash
dart format lib/
```

**Format specific file:**

```bash
dart format lib/features/incomes/presentation/add_income_page.dart
```

---

### `dart analyze`

**Context:** Check for Dart errors and warnings

**What it does:**

- Static analysis of Dart code
- Reports compilation errors
- Identifies warnings and style issues
- Uses analysis_options.yaml configuration

**Example:**

```bash
dart analyze lib/
```

**Sample Output:**

```
No issues found!
```

---

## Build Runner Commands

### `dart run build_runner build --delete-conflicting-outputs`

**Context:** Force rebuild when there are conflicting outputs

**What it does:**

- Deletes conflicting generated files
- Forces complete regeneration
- Useful when generators fail with conflicts

**Example:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**When to use:** After major refactoring or generator updates

---

### `dart run build_runner watch --delete-conflicting-outputs`

**Context:** Watch mode with automatic conflict resolution

**What it does:**

- Watches for changes with auto-cleanup
- Automatically handles conflicting outputs
- Useful during development with schema changes

**Example:**

```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## Database Commands

### Add a new database migration (Drift)

**Context:** After modifying database tables

**What it does:**

- Increment `schemaVersion` in app_database.dart
- Run `dart run build_runner build` to regenerate
- Drift automatically handles migrations

**Example:**

1. Update [lib/core/database/app_database.dart](lib/core/database/app_database.dart):

```dart
@override
int get schemaVersion => 2;  // Was 1, now 2
```

2. Add new table or modify existing table

3. Regenerate:

```bash
dart run build_runner build
```

---

### Execute SQL queries directly (for debugging)

**Context:** Debug database state or test queries

**What it does:**

- Uses Drift's `customSelect()` for raw SQL
- Useful for complex queries or debugging
- Limited to read-only by default

**Example in code:**

```dart
// In repository or debug console
final result = await database.customSelect(
  'SELECT * FROM incomes_table WHERE amount > ?',
  variables: [1000],
).get();
```

---

## Development & Debugging

### `flutter run -d windows -v`

**Context:** Run app with verbose logging

**What it does:**

- Prints detailed build information
- Shows all Flutter operations
- Useful for debugging build issues

**Example:**

```bash
flutter run -d windows -v
```

---

### `flutter run -d windows --profile`

**Context:** Run app in profile mode for performance testing

**What it does:**

- Disables debug checks
- Optimizes performance
- Enables performance profiling
- Slower build than debug

**Example:**

```bash
flutter run -d windows --profile
```

---

### `flutter run -d windows --release`

**Context:** Run app in production mode

**What it does:**

- Maximum optimizations
- No debug information
- Closest to production behavior
- Slowest to build

**Example:**

```bash
flutter run -d windows --release
```

---

### Hot Reload (During `flutter run`)

**Context:** Update code without restarting the app

**What it does:**

- Applies code changes instantly
- Preserves app state
- Doesn't work for all changes
- Triggered by pressing `r`

**Example (in terminal running app):**

```
flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.

> r
Performing hot reload...
Reloaded 5 libraries in 300ms.
```

---

### Hot Restart (During `flutter run`)

**Context:** Restart app while keeping debugger

**What it does:**

- Restarts the Flutter app completely
- Resets app state
- Keeps debugger attached
- Triggered by pressing `R`

**Example (in terminal running app):**

```
> R
Performing hot restart...
Restarted application in 800ms.
```

---

### Detach (During `flutter run`)

**Context:** Keep app running after stopping `flutter run`

**What it does:**

- Exits Flutter runner
- App continues running
- Debugger detaches
- Triggered by pressing `d`

**Example (in terminal running app):**

```
> d
Detaching from device...
Application still running on Windows.
```

---

## Clean & Reset

### `flutter clean && flutter pub get && dart run build_runner build`

**Context:** Complete clean rebuild from scratch

**What it does:**

1. Removes all build artifacts
2. Reinstalls dependencies
3. Regenerates all code
4. Full reset of development environment

**Example:**

```bash
cd c:\Users\asanc\mini_finance_manager
flutter clean
flutter pub get
dart run build_runner build
```

**When to use:**

- After major dependency updates
- When experiencing persistent build errors
- After environment issues
- Before sharing project with team

---

### `flutter clean`

**Context:** Remove build directory

**What it does:**

- Deletes build/ folder
- Removes all compiled binaries
- Resets build state

**Example:**

```bash
flutter clean
```

---

## Development Workflow

### Typical Daily Workflow

```bash
# Start of day or after pulling changes
flutter pub get

# Start development
flutter run -d windows

# During development, press 'r' in terminal for hot reload
# Press 'R' for hot restart if hot reload doesn't work
# Press 'q' to quit

# After modifying database schema
dart run build_runner build
flutter run -d windows

# Before committing
dart format lib/
dart analyze
flutter test
```

---

### Adding New Dependency

```bash
# Add to pubspec.yaml manually or using:
flutter pub add package_name

# Install it
flutter pub get

# If it has code generation requirements:
dart run build_runner build

# Run app to verify
flutter run -d windows
```

---

### Debugging Workflow

```bash
# Run with verbose output
flutter run -d windows -v

# Check code analysis
dart analyze

# Format code
dart format lib/

# View generated files (for Drift)
# Navigate to lib/core/database/app_database.g.dart
```

---

## Quick Reference Table

| Command                       | Purpose       | Time    | Usage                 |
| ----------------------------- | ------------- | ------- | --------------------- |
| `flutter run -d windows`      | Launch app    | ~20s    | Daily dev             |
| `flutter pub get`             | Install deps  | ~10s    | After pubspec changes |
| `dart run build_runner build` | Generate code | ~35s    | After schema changes  |
| `flutter clean`               | Reset build   | ~5s     | Troubleshooting       |
| `dart format lib/`            | Format code   | ~3s     | Before commit         |
| `dart analyze`                | Check errors  | ~5s     | Before commit         |
| `r` (in flutter run)          | Hot reload    | ~1s     | During dev            |
| `R` (in flutter run)          | Hot restart   | ~3s     | When hot reload fails |
| `q` (in flutter run)          | Quit app      | instant | End session           |

---

## Troubleshooting Commands

### If app won't build:

```bash
flutter clean
flutter pub get
dart run build_runner build
flutter run -d windows -v
```

### If hot reload doesn't work:

```bash
# In terminal running flutter: press 'R' for hot restart
# Or try:
flutter run -d windows
```

### If database queries fail:

```bash
# Verify database was generated
ls lib/core/database/app_database.g.dart

# Rebuild if missing:
dart run build_runner build --delete-conflicting-outputs
```

### If dependencies conflict:

```bash
flutter pub get
flutter pub upgrade
flutter pub outdated
```

---

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Project README](README.md)

---

**Last Updated:** April 23, 2026
**Project:** Mini Finance Manager v1.0.0
