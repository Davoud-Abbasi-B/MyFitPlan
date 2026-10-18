# Fitora

**Offline-first Persian health and fitness planner built with Flutter.**

Fitora is a personal health companion for organizing workouts, nutrition, supplements, daily habits, cravings, and body-progress tracking in one focused mobile experience. The app is designed around fast daily check-ins, clear progress visibility, and local-first privacy.

## Why I built it

I wanted a lightweight product that could turn a complete health routine into something actionable day by day: what to train, what to eat, what to remember, and how progress is changing over time.

This project is also part of my hands-on **AI-assisted product-building workflow**. I used **OpenAI Codex + VS Code** to accelerate implementation, debugging, refactoring, and iteration while owning the product decisions, requirements, testing, and release workflow.

## Core features

- Persian-first RTL interface
- Daily dashboard and health checklist
- Structured workout plans
- Exercise logging and workout history
- Nutrition planning and nutrition history
- Craving-management flow
- Supplement tracking and reminders
- Weight and body-progress tracking
- Local notifications
- Offline-first local data storage
- Settings and personalized health routines

## Product structure

The app is organized by feature rather than as one monolithic screen:

- **Dashboard** — daily overview and quick actions
- **Checklist** — habit completion and daily score
- **Workout** — training plan, exercise details, logs, and history
- **Nutrition** — daily nutrition plan and history
- **Craving** — guided flow for managing snack/craving moments
- **Supplements** — supplement schedule and completion tracking
- **Progress** — body-progress records
- **Settings / More** — personal preferences and supporting tools

## Tech stack

- **Flutter / Dart**
- **Riverpod** for state management
- **Hive / Hive Flutter** for local persistence
- **flutter_local_notifications** for reminders
- **intl + timezone** for date/time handling
- **Vazirmatn** for Persian typography
- Feature-based application structure

## Architecture & product principles

- **Offline-first:** the core product does not depend on a backend to work.
- **Local data ownership:** health and routine data is stored on-device.
- **Persian UX:** RTL layout and Persian-first interactions are treated as product requirements, not an afterthought.
- **Fast daily usage:** core actions are designed around short, repeatable check-ins.
- **Modular feature structure:** workout, nutrition, progress, supplements, and other domains are separated for maintainability.

## AI-assisted development

This is not a generated demo project. It has been iterated as a working product using an AI-assisted development process.

My workflow included:

1. Defining the product requirements and user flows
2. Breaking features into small implementation tasks
3. Using OpenAI Codex inside the development workflow
4. Reviewing and debugging generated changes
5. Testing flows on the actual application
6. Iterating on UX, state handling, and release issues

The goal was to use AI as a **shipping accelerator**, while keeping product ownership and validation human-led.

## Run locally

Prerequisites:

- Flutter SDK
- Dart
- Android Studio / Android SDK or another Flutter-compatible environment

```bash
flutter pub get
flutter run
```

Useful checks:

```bash
flutter analyze
flutter test
```

## Repository notes

- The application currently uses local persistence rather than a cloud backend.
- Personal production data is not stored in the repository.
- The UI supports Persian and uses RTL directionality throughout the main experience.

## Portfolio context

Fitora demonstrates my ability to go beyond marketing execution and **build a functional consumer product with AI-assisted development tools**—from requirements and user flows to implementation, debugging, iteration, and release preparation.

---

Built by **Davoud Abbasi**  
Growth marketer & AI-assisted product builder
