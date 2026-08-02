# Engineering Rules

**Project:** Perductivity (Working Title)  
**Version:** 1.0.0  
**Status:** Required

---

# Purpose

This document defines the engineering standards that every contributor, AI coding agent, and future maintainer must follow.

These rules are **mandatory**, not recommendations.

If a rule conflicts with generated code, the rule takes precedence.

---

# Core Principles

The project must always prioritize:

- Readability
- Maintainability
- Simplicity
- Scalability
- Testability
- Consistency
- Performance
- Security

Never sacrifice long-term maintainability for short-term convenience.

---

# SOLID

Every implementation must follow the SOLID principles.

## S — Single Responsibility Principle

Each class, service, repository, provider, and widget must have one clear responsibility.

Avoid "God Classes."

---

## O — Open/Closed Principle

Software should be open for extension but closed for modification.

Prefer interfaces and abstractions.

---

## L — Liskov Substitution Principle

Child implementations must behave exactly like their parent contracts.

---

## I — Interface Segregation Principle

Prefer multiple focused interfaces over one large interface.

---

## D — Dependency Inversion Principle

Depend on abstractions.

Never depend directly on implementations.

---

# DRY (Don't Repeat Yourself)

Repeated logic must be extracted.

If identical logic appears **4 or more times**, refactor into one of:

- Utility
- Service
- Repository
- Extension
- Widget
- Component
- Helper
- Shared Function

Do not duplicate business logic.

---

# KISS (Keep It Simple, Stupid)

Always implement the simplest solution that satisfies the requirements.

Avoid:

- Premature optimization
- Clever code
- Overengineering
- Unnecessary abstraction

Readable code is preferred over complex code.

---

# YAGNI (You Aren't Gonna Need It)

Never implement features that are not currently required.

Do not add:

- Placeholder classes
- Unused services
- Empty repositories
- Future APIs
- Speculative abstractions

Only build what is required.

---

# Feature Development

Every new feature must follow this order:

1. Update documentation
2. Create models/entities
3. Create database schema (if needed)
4. Create data source
5. Create repository
6. Create provider/state management
7. Build UI
8. Write tests
9. Update documentation

Never skip steps.

---

# Architecture

Must follow:

- Clean Architecture
- Feature First
- Repository Pattern
- Dependency Injection
- Offline First

Never violate ARCHITECTURE.md.

---

# Folder Rules

Every feature owns its own:

- Models
- Providers
- Repositories
- Screens
- Widgets
- Services

Never place feature-specific code in `/shared`.

---

# Widgets

Widgets must remain presentation only.

Widgets must NEVER:

- Query databases
- Contain business logic
- Call APIs directly
- Store application state

Widgets should receive data only through providers.

---

# Business Logic

Business logic belongs in:

- Use Cases
- Services
- Repositories

Never inside:

- Widgets
- Screens
- Dialogs

---

# State Management

State management uses Riverpod.

Rules:

- Immutable state
- Small providers
- One responsibility per provider
- No business logic in UI

---

# Repository Rules

Repositories are the only layer allowed to coordinate between:

- Local Database
- Future Remote API

Repositories hide implementation details.

The UI must never know where data originates.

---

# Database Rules

Only data sources communicate with the database.

Never access:

- Hive
- Drift
- SQLite

directly from:

- Widgets
- Providers
- Screens

---

# Dependency Injection

Never instantiate services manually inside widgets.

Dependencies must be injected using Riverpod.

Avoid global singletons unless explicitly required.

---

# Models

Models should:

- Be immutable
- Use value equality
- Support serialization
- Be strongly typed

Avoid dynamic types whenever possible.

---

# Functions

Functions should:

- Have one responsibility
- Be concise
- Return predictable values
- Avoid side effects

Target maximum length:

30 lines

Refactor when necessary.

---

# Classes

Classes should remain focused.

Target maximum:

300 lines

Large classes should be split.

---

# Files

Target maximum:

500 lines

Split large files into smaller modules.

---

# Naming Convention

## Files

snake_case.dart

Example

```
task_repository.dart
```

---

## Classes

PascalCase

```
TaskRepository
```

---

## Variables

camelCase

```
taskRepository
```

---

## Constants

camelCase for runtime constants.

UPPER_SNAKE_CASE only for compile-time constants.

---

## Private Members

Prefix with underscore.

```
_taskRepository
```

---

# Error Handling

Never ignore exceptions.

Never swallow errors.

Use:

- Result
- Failure
- Exception Mapping

Provide meaningful messages.

---

# Logging

Never use:

```dart
print();
```

Use centralized logging.

Log Levels:

- Debug
- Info
- Warning
- Error
- Critical

---

# Async Rules

Prefer:

```dart
async / await
```

Avoid nested Future chains.

Always handle asynchronous errors.

---

# Performance

Always:

- Use const constructors
- Minimize rebuilds
- Cache expensive computations
- Lazy load data
- Paginate large datasets (future)

Never rebuild the entire widget tree unnecessarily.

---

# Reusable Components

If a widget appears more than three times:

Extract it.

If logic appears four or more times:

Extract it.

---

# Design System

Never hardcode:

- Colors
- Spacing
- Radius
- Typography
- Animation Duration

Use design tokens defined in DESIGN.md.

---

# Accessibility

Every interactive element must:

- Have semantic labels
- Meet 48x48 touch targets
- Meet WCAG AA contrast requirements

Do not rely solely on color to convey information.

---

# Responsive Design

All screens must support:

- Mobile
- Tablet
- Desktop

Avoid fixed widths.

---

# Packages

Only use packages that are:

- Free
- Open Source
- Well Maintained
- Actively Supported

Before adding a package verify:

- Latest release
- License
- Community activity
- Compatibility

Avoid unnecessary dependencies.

---

# Free Services Policy

The project must rely on free services.

Preferred:

- Flutter
- Riverpod
- Drift
- Hive
- SQLite
- GoRouter
- Supabase Free
- Firebase Spark
- GitHub
- GitHub Actions
- Figma Free
- Penpot

Never require paid services for the MVP.

---

# Security

Never:

- Hardcode API Keys
- Commit secrets
- Store passwords in plain text
- Log sensitive information

Use secure storage where appropriate.

---

# Documentation

Every public:

- Service
- Repository
- Provider
- Utility

must include DartDoc comments.

Update documentation whenever architecture or requirements change.

---

# Git Workflow

Branch naming:

```
feature/task-management
bugfix/calendar
refactor/database
docs/prd-update
```

Commit format:

```
feat:
fix:
refactor:
docs:
style:
test:
perf:
build:
ci:
chore:
```

Example:

```
feat(tasks): add task filtering
```

---

# Code Reviews

Before considering work complete, verify:

- Compiles successfully
- No warnings
- No analyzer issues
- No duplicated logic
- No architecture violations
- Documentation updated
- Design system followed
- Tests pass

---

# AI Coding Rules

When implementing a feature, always:

1. Read PRD.md.
2. Read DESIGN.md.
3. Read ARCHITECTURE.md.
4. Read SCHEMA.md.
5. Read RULES.md.

Never assume undocumented requirements.

If documentation is ambiguous:

Stop and ask for clarification.

Do not invent functionality.

Do not modify unrelated files.

Do not refactor unrelated code.

Keep pull requests focused.

---

# Prohibited Practices

Never:

- Use print() for debugging in production
- Ignore exceptions
- Duplicate business logic
- Hardcode configuration
- Place business logic inside widgets
- Directly access databases from UI
- Introduce circular dependencies
- Use global mutable state
- Add unnecessary packages
- Leave TODO or FIXME comments in production
- Commit commented-out code
- Commit unused code
- Commit dead code

---

# Definition of Done

A task is complete only when:

- Requirements are fully implemented.
- Code follows SOLID, DRY, KISS, and YAGNI.
- Architecture is respected.
- Design system is respected.
- Documentation is updated.
- Tests pass.
- No analyzer warnings remain.
- No duplicate logic exists.
- Code is production-ready.
- The feature integrates cleanly without regressions.

---

# Rule Authority

This document is the highest authority for engineering standards.

If generated code violates these rules, the code must be corrected before it is accepted.

## Scalability Rule

Every new feature must answer the following questions before implementation:

1. Is it modular?
2. Can it be replaced?
3. Can it scale to 100× more data?
4. Can it support cloud synchronization?
5. Can it support future AI integration?
6. Does it introduce unnecessary coupling?
7. Does it require modifying unrelated features?

If the answer to any of these is "yes" (except #5 when not applicable), redesign the implementation before proceeding.
