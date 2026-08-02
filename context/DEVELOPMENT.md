# Development Guide

**Project:** Perductivity  
**Version:** 1.0.0

---

# Purpose

This document defines the implementation workflow for the project.

Every feature must be developed according to this guide.

Never skip phases.

Documentation always comes before implementation.

---

# Development Lifecycle

Every feature follows the same lifecycle.

```
Requirements
      ↓
Planning
      ↓
Architecture
      ↓
Database
      ↓
Domain
      ↓
Data Layer
      ↓
State Management
      ↓
UI
      ↓
Testing
      ↓
Review
      ↓
Documentation
```

---

# Development Order

The project must be implemented in this order.

## Phase 1

Project Foundation

Tasks

- Flutter project setup
- Folder structure
- Git initialization
- CI configuration
- Theme setup
- Routing
- Design Tokens
- Dependency Injection
- Database initialization

Deliverable

Application launches successfully.

---

## Phase 2

Core Infrastructure

Implement

- App Theme
- Navigation
- Database
- Logging
- Error Handling
- Shared Widgets
- Core Utilities

Deliverable

Foundation complete.

---

## Phase 3

Categories Feature

Implement

- Database
- Models
- Repository
- Providers
- UI
- CRUD

Deliverable

Categories fully functional.

---

## Phase 4

Task Feature

Implement

- Task Entity
- CRUD
- Priority
- Status
- Search
- Filter
- Sort
- Archive
- History

Deliverable

Complete task management.

---

## Phase 5

Dashboard

Implement

- Today's Tasks
- Upcoming Deadlines
- Statistics
- Quick Actions

Deliverable

Dashboard complete.

---

## Phase 6

Calendar

Implement

- Monthly View
- Daily Tasks
- Navigation
- Task Indicators

Deliverable

Calendar complete.

---

## Phase 7

Statistics

Implement

- Weekly Progress
- Monthly Progress
- Completion Rate
- Charts

Deliverable

Analytics complete.

---

## Phase 8

Settings

Implement

- Theme
- Preferences
- About

Deliverable

Settings complete.

---

## Phase 9

Testing

Implement

- Unit Tests
- Widget Tests
- Integration Tests

---

## Phase 10

Optimization

Perform

- Performance Optimization
- Refactoring
- Dead Code Removal
- Analyzer Cleanup

---

## Phase 11

Release

Generate

- Release Build
- Documentation
- Changelog

---

# Implementation Workflow

For every feature:

Step 1

Read

- PRD.md
- DESIGN.md
- ARCHITECTURE.md
- SCHEMA.md
- RULES.md

---

Step 2

Understand requirements.

Do not assume functionality.

---

Step 3

Create data model.

---

Step 4

Update database.

---

Step 5

Implement repository.

---

Step 6

Implement providers.

---

Step 7

Implement UI.

---

Step 8

Write tests.

---

Step 9

Verify functionality.

---

Step 10

Update documentation.

---

# File Creation Order

When creating a new feature.

```
Feature

↓

Entity

↓

Model

↓

Database Table

↓

Datasource

↓

Repository

↓

Provider

↓

Widgets

↓

Screens

↓

Tests
```

Never create UI first.

---

# Feature Checklist

Before starting.

- Requirements understood
- Database reviewed
- Existing components checked
- Reuse opportunities identified

Before finishing.

- Tests pass
- Analyzer clean
- Documentation updated
- Responsive
- Accessible
- Dark mode works

---

# Git Workflow

Never work on main.

```
main

↓

develop

↓

feature/xxx
```

Branch examples

```
feature/tasks

feature/dashboard

feature/calendar

fix/task-filter

docs/prd

refactor/database
```

---

# Commit Format

Use Conventional Commits.

Examples

```
feat(tasks): add CRUD

fix(calendar): resolve navigation bug

docs(prd): update requirements

refactor(database): simplify repository

test(tasks): add repository tests
```

---

# Pull Request Checklist

Every PR must:

- Compile successfully
- Pass tests
- Follow architecture
- Follow design
- Follow schema
- Follow engineering rules

---

# Code Generation Rules

The AI must generate code incrementally.

Never generate an entire application in one response.

Maximum implementation size:

One feature at a time.

---

# Refactoring Rules

Only refactor when:

- Duplicate code exists
- Architecture violation exists
- Performance issue exists

Never refactor unrelated code.

---

# Package Rules

Before adding any package verify:

- Free
- Open Source
- Well maintained
- Compatible
- Necessary

Avoid dependency bloat.

---

# Testing Requirements

Every feature requires:

Unit Tests

Business Logic

Widget Tests

Critical UI

Integration Tests

Core workflows

---

# Performance Targets

Startup

<2 seconds

Screen Transition

<300ms

Task CRUD

<200ms

Database Query

<100ms

---

# Documentation Rules

Whenever code changes:

Update

- PRD (if requirements changed)
- DESIGN (if UI changed)
- ARCHITECTURE (if structure changed)
- SCHEMA (if database changed)
- RULES (if engineering standards changed)

Documentation is always updated before implementation is considered complete.

---

# AI Agent Rules

Always:

- Read all documentation first.
- Search for reusable code before writing new code.
- Reuse existing widgets.
- Reuse repositories.
- Reuse services.
- Keep features independent.

Never:

- Invent requirements.
- Skip documentation.
- Modify unrelated files.
- Introduce paid services.
- Break architecture.
- Ignore analyzer warnings.
- Leave TODO comments.
- Leave placeholder implementations.

---

# Definition of Complete

A development phase is complete only if:

- Feature fully implemented.
- Documentation updated.
- Tests passing.
- Analyzer clean.
- Architecture respected.
- Design system respected.
- Database schema respected.
- Responsive.
- Accessible.
- Production-ready.

No phase is complete until all conditions are satisfied.
