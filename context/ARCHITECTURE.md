# Architecture Specification

**Project:** Perductivity (Working Title)  
**Version:** 1.0.0  
**Status:** Draft

---

# 1. Purpose

This document defines the software architecture for Perductivity.

Its purpose is to ensure the application is:

- Scalable
- Maintainable
- Testable
- Modular
- Performant
- Offline First

Every implementation must follow this document.

---

# 2. Architecture Goals

The architecture must:

- Be easy to understand.
- Separate concerns.
- Minimize coupling.
- Maximize cohesion.
- Be feature-oriented.
- Support future expansion.
- Allow independent testing.
- Support Android, iOS, Windows, macOS, Linux, and Web.
- Support future backend integration without major refactoring.

---

# 3. Architectural Principles

The project follows:

- Clean Architecture
- SOLID
- DRY
- KISS
- YAGNI
- Composition over Inheritance
- Repository Pattern
- Dependency Injection
- Offline First

---

# 4. High-Level Architecture

```text
                Presentation Layer
                       │
             Screens / Widgets
                       │
                 Riverpod Providers
                       │
                  Use Cases (Optional)
                       │
                 Repository Layer
                       │
        Local Data Source / Remote Data Source
                       │
          Hive / Drift / Future Cloud APIs
```

Responsibilities

Presentation

- Display UI
- User interactions

Providers

- Manage application state
- Expose data to UI

Repository

- Business logic
- Data abstraction

Data Source

- Read and write data

Storage

- Local persistence

---

# 5. Architecture Style

Feature First

Every feature owns its:

- UI
- Providers
- Models
- Repository
- Services
- Widgets

No feature should directly depend on another feature.

Shared functionality belongs inside `/shared`.

---

# 6. Project Structure

```text
lib/
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── theme.dart
│   └── bootstrap.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── utils/
│   ├── services/
│   ├── database/
│   ├── network/
│   ├── logging/
│   └── config/
│
├── shared/
│   ├── widgets/
│   ├── models/
│   ├── providers/
│   ├── components/
│   ├── dialogs/
│   └── themes/
│
├── features/
│   │
│   ├── home/
│   ├── tasks/
│   ├── categories/
│   ├── calendar/
│   ├── statistics/
│   └── settings/
│
└── main.dart
```

---

# 7. Feature Structure

Every feature follows the same structure.

```text
tasks/

├── data/
│   ├── datasource/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── presentation/
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   └── controllers/
│
└── task_feature.dart
```

Each feature is isolated.

---

# 8. Layer Responsibilities

## Presentation

Contains

- Screens
- Widgets
- Dialogs

Must NOT

- Access database
- Perform business logic

---

## Providers

Responsible for

- UI State
- Loading
- Error
- Refresh

Must NOT

- Query database directly

---

## Domain

Contains

- Business Rules
- Entities
- Use Cases

No Flutter imports.

---

## Repository

Responsible for

- Data abstraction
- Combining local/remote sources

---

## Data Source

Responsible only for

CRUD operations.

---

# 9. State Management

State management uses

Riverpod

Types

- Provider
- StateNotifierProvider
- FutureProvider
- StreamProvider

Guidelines

- Keep state immutable.
- Avoid global mutable state.
- Business logic belongs outside widgets.

---

# 10. Navigation

Navigation uses

GoRouter

Structure

```text
Splash

↓

Home

├── Tasks
├── Calendar
├── Statistics
└── Settings
```

Deep linking should be supported in future versions.

---

# 11. Data Flow

```text
User

↓

Widget

↓

Provider

↓

Use Case

↓

Repository

↓

Data Source

↓

Database

↓

Repository

↓

Provider

↓

Widget

↓

User
```

All writes follow the same path.

---

# 12. Dependency Flow

Allowed

```text
Presentation

↓

Domain

↓

Repository

↓

Data Source
```

Forbidden

```text
Widget

↓

Database
```

Forbidden

```text
Widget

↓

Hive
```

Forbidden

```text
Provider

↓

SQLite
```

---

# 13. Dependency Injection

Dependencies should be injected.

Never instantiate repositories inside widgets.

Example

```text
Provider

↓

Repository

↓

Data Source
```

Use Riverpod providers for dependency injection.

---

# 14. Repository Pattern

Repositories abstract data sources.

Example

```text
TaskRepository

↓

Local Database

Future

↓

Remote API
```

UI never knows where data originates.

---

# 15. Database Strategy

Current

Offline First

Future

Offline + Cloud Sync

Database responsibilities

- Persist data
- Cache data
- Fast lookup

---

# 16. Error Handling

Never expose exceptions to UI.

Use

```text
Success

Failure
```

Return typed errors.

Example

```text
TaskFailure

DatabaseFailure

ValidationFailure

UnknownFailure
```

---

# 17. Logging

Centralized logging only.

Never use

print()

Instead

Logger Service

Levels

Debug

Info

Warning

Error

Critical

---

# 18. Configuration

Environment configuration stored separately.

Examples

```text
dev

staging

production
```

No secrets inside source code.

---

# 19. Security

Never

- Hardcode API Keys
- Hardcode Tokens
- Store passwords in plain text

Future

Secure Storage

---

# 20. Offline First

The application must remain usable without internet.

All core functionality must work offline.

Future synchronization should happen transparently.

---

# 21. Performance

Goals

Startup

<2s

Navigation

<300ms

Database Query

<100ms

Avoid

- Unnecessary rebuilds
- Large widget trees
- Expensive synchronous work

---

# 22. Scalability

Architecture should support

- AI Assistant
- Cloud Sync
- Notifications
- Attachments
- Teams
- Collaboration

Without restructuring the project.

---

# 23. Testing Strategy

Three levels

Unit Tests

Widget Tests

Integration Tests

Business logic should be independently testable.

---

# 24. Coding Standards

Every layer should have one responsibility.

Avoid

God Classes

Massive Widgets

Massive Providers

Duplicate Logic

---

# 25. Design Patterns

Mandatory

- Repository Pattern
- Dependency Injection
- Observer (Riverpod)
- Factory Constructors
- Immutable Models

Optional

- Strategy Pattern
- Command Pattern
- Adapter Pattern
- Builder Pattern

Avoid unnecessary patterns.

---

# 26. Module Communication

Features communicate only through

- Shared Models
- Repository Interfaces
- Services

Never import another feature's internal implementation.

---

# 27. Shared Layer

Shared contains

Widgets

Components

Dialogs

Utilities

Extensions

Themes

Models

Services

Nothing feature-specific belongs here.

---

# 28. Future Backend Architecture

Future Architecture

```text
Flutter

↓

Repository

↓

Remote API

↓

Supabase / Appwrite / Firebase

↓

Database
```

Repositories must allow swapping local and remote implementations.

---

# 29. Free Technology Stack

The project must use free or open-source technologies.

Approved

Flutter

Riverpod

GoRouter

Hive

Drift

SQLite

Supabase Free Tier

Firebase Spark

GitHub

GitHub Actions

Figma Free

Penpot

Flutter Local Notifications

No paid dependencies are allowed unless explicitly approved.

---

# 30. Architecture Decision Records (ADR)

Major architectural changes must be documented.

Examples

- Why Drift over Hive?
- Why Riverpod over Bloc?
- Why Feature-First?
- Why Repository Pattern?

Never change architecture without updating documentation.

---

# 31. Architecture Rules

Always

- Follow Clean Architecture.
- Keep features independent.
- Keep dependencies flowing downward.
- Keep business logic out of UI.
- Keep repositories abstract.
- Keep models immutable.
- Prefer composition.
- Prefer dependency injection.
- Write modular code.
- Document public APIs.

Never

- Access the database directly from widgets.
- Place business logic inside screens.
- Create circular dependencies.
- Share mutable state globally.
- Hardcode configuration values.
- Duplicate business logic.

---

# 32. Definition of Done

A feature is architecturally complete when:

- It follows the folder structure.
- Dependencies flow correctly.
- No architecture violations exist.
- Business logic is isolated.
- UI remains presentation-only.
- State is managed through Riverpod.
- Repository pattern is respected.
- Tests pass.
- Documentation is updated.
- Future extensibility is preserved.

---

# 33. Architecture Governance

This document is the authoritative reference for all architectural decisions.

Any implementation that violates this architecture must be refactored or rejected unless this document is formally updated.

# Scalability Strategy

## Goal

The architecture must support future growth without requiring major refactoring.

The system should scale in terms of:

- Features
- Users
- Data
- Platforms
- Developers
- Infrastructure

---

## Feature Scalability

Every feature must be independent.

Each feature owns:

- models
- repositories
- providers
- services
- screens
- widgets

Adding a new feature must not require modifying existing features.

---

## Data Scalability

Current

```
Flutter
    ↓
Drift (SQLite)
```

Future

```
Flutter
      ↓
Repository
      ↓
Local Database
      ↓
Sync Layer
      ↓
Supabase / Firebase / Appwrite
```

Repositories must support multiple data sources.

---

## Modular Scalability

Future modules should plug into the existing architecture.

Examples

- AI Assistant
- Notifications
- Projects
- Habits
- Attachments
- Collaboration

without changing existing modules.

---

## State Scalability

Providers should remain feature-scoped.

Avoid giant global providers.

One provider should manage one responsibility.

---

## Database Scalability

Every table belongs to a feature.

Future tables:

- projects
- reminders
- notifications
- attachments
- tags
- sync_queue

should integrate without schema redesign.

---

## UI Scalability

Every screen must be composed of reusable widgets.

Avoid widgets exceeding 250 lines.

Large screens should be split into sections.

---

## Service Scalability

Services must be replaceable.

Current

```
Local Notification Service
```

Future

```
Firebase Messaging
```

should require changing only the service implementation.

---

## AI Scalability

Future AI providers should be interchangeable.

Current

No AI

Future

Repository

↓

AI Interface

↓

Gemini

Claude

OpenAI

OpenRouter

Ollama

No feature should depend on a specific AI provider.

---

## Cloud Scalability

MVP

Offline only

Future

Offline

↓

Sync Queue

↓

Background Sync

↓

Cloud

Users should never lose local functionality.

---

## Platform Scalability

Support

- Android
- iOS
- Windows
- macOS
- Linux
- Web

Platform-specific code must remain isolated.

---

## Team Scalability

Developers should be able to work on separate features without merge conflicts.

Feature ownership should minimize cross-feature dependencies.

---

## Performance Scalability

The architecture should continue performing efficiently with:

- 100,000+ tasks
- 1,000+ categories
- Years of task history

Use:

- pagination
- lazy loading
- indexes
- efficient queries

where appropriate.

---

## Migration Strategy

Architecture should allow:

SQLite

↓

SQLite + Cloud

↓

Cloud-first

without rewriting business logic.

Repositories are responsible for this abstraction.

---

## Scalability Rules

Always

- Keep features independent.
- Keep repositories abstract.
- Keep services replaceable.
- Prefer composition.
- Minimize coupling.
- Maximize cohesion.

Never

- Hardcode providers.
- Couple UI to storage.
- Couple UI to APIs.
- Couple features together.
