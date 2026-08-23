# Perductivity

Perductivity is an offline-first Flutter productivity app for managing tasks,
categories, schedules, and progress in one workspace.

## Current Features

- Task creation, editing, completion, archiving, pinning, and deletion
- Recurring tasks with automatic next-occurrence scheduling
- Subtasks for breaking larger tasks into manageable steps
- Task filtering by status, due date, and pinned state
- Category management with colors and icons
- Home dashboard with today's tasks and upcoming deadlines
- Monthly calendar with task indicators
- Completion and priority statistics
- Light, dark, and system themes
- Local persistence with Drift and SQLite

## Development

Requirements:

- Flutter SDK compatible with Dart `3.12.2` or newer within the declared SDK range

Install dependencies and run checks:

```bash
flutter pub get
dart analyze
flutter test
flutter run
```

The application is designed to work without an internet connection after its
dependencies have been installed.

## Architecture

The codebase follows a feature-first structure with Riverpod state management,
GoRouter navigation, repository abstractions, and Drift data sources:

```text
lib/
├── app/
├── core/
├── shared/
└── features/
    ├── home/
    ├── tasks/
    ├── categories/
    ├── calendar/
    ├── statistics/
    └── settings/
```

Product, design, schema, architecture, and engineering guidance is maintained
in the `context/` directory.
