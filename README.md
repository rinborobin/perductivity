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

## Moodle Integration

The first Moodle integration milestone supports secure connection testing and
read-only previews of enrolled courses and assignments.

1. Enable Moodle web services and the REST protocol on your Moodle site.
2. Create a web-service token for the user account that should be connected.
3. Open `Settings -> Moodle` in Perductivity.
4. Enter the Moodle site URL and token, then select `Test connection`.

The token is stored using platform secure storage. Moodle data is currently
preview-only and is not imported into local tasks yet.

### Moodle Calendar Import

If you cannot obtain a web-service token from your Moodle administrator, you can
import events from a Moodle iCal export URL instead.

1. In Moodle, go to **Calendar → Export calendar** and copy the iCal URL.
2. Open `Settings -> Moodle` in Perductivity.
3. Paste the URL under **Calendar import** and select `Import calendar`.

Events are imported as tasks in a `Moodle` category and appear in the app
calendar. Re-importing the same URL updates existing tasks and adds new ones.

### AI Planner

The AI Planner turns a monthly schedule into a day-by-day to-do list using
Google Gemini (free tier supported).

1. Open `Settings -> AI Planner`.
2. Enter your Gemini API key and model (defaults to `gemini-2.5-flash`). The key
   is stored securely on this device.
3. Choose your inputs, then select `Generate plan`:
   - **Moodle calendar link**: paste the iCal export URL (prefilled from the
     saved Moodle link). Events become dated tasks for the AI.
   - **Syllabus (PDF)**: attach a PDF; it is sent to Gemini as input so the
     model can read the syllabus directly.
   - **Markdown**: attach a `.md`/`.txt` file with your plan or notes.
   - **Include imported events**: reuse tasks already in the app this month.
   - **Extra notes**: a short free-text context block.
4. Review the per-day plan. Each task can be selected or deselected.
5. Select `Confirm selected` to add the chosen tasks (with sub-tasks) to the app
   calendar under an `AI Plan` category.

The AI only generates a draft; nothing is saved until you confirm.
