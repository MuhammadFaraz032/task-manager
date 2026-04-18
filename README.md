# TaskFlow – Task Management Dashboard

A production-ready task management application built with **Flutter** and **BLoC** state management, powered by Firebase backend. This project demonstrates real-world mobile development patterns including clean architecture, real-time data sync, and comprehensive state management.

| Technology | Version |
|------------|---------|
| Flutter | 3.x |
| BLoC | 8.x |
| Firebase | Latest |
| Status | MVP Complete |

---

## Live Demo

| Platform | Link |
|----------|------|
| APK Download | [Add Google Drive link here] |
| Portfolio | [Add your portfolio link here] |

> Screenshots will be added shortly.

---

## Features

### MVP Complete (Current Version)

| Feature | Status | Description |
|---------|--------|-------------|
| Email/Password Auth | Complete | Login, register, auto-login persistence |
| Workspace Management | Complete | Single default workspace per user |
| Project CRUD | Complete | Create, edit, delete projects with color coding |
| Task CRUD | Complete | Create, edit, delete tasks within projects |
| Task Prioritization | Complete | Low / Medium / High priority levels |
| Due Dates | Complete | Set and track task deadlines |
| Completion Status | Complete | Mark tasks as complete or incomplete |
| Basic Filtering | Complete | All / Active / Completed tasks |
| Dark/Light Theme | Complete | System-aware theme with manual toggle |
| Real-time Sync | Complete | Firestore listeners for cross-device updates |
| Loading & Error States | Complete | Proper UI feedback for async operations |

### Phase 2 (Planned)

| Feature | Target | Description |
|---------|--------|-------------|
| Task Comments | Week 1 | Add comments and discussions on tasks |
| File Attachments | Week 2 | Upload images and documents to tasks |
| Push Notifications | Week 3 | Firebase Cloud Messaging integration |
| Team Collaboration | Week 4 | Invite users, assign tasks to team members |
| Advanced Filters | Week 5 | Filter by priority, due date range, assignee |
| Task Search | Week 5 | Full-text search across tasks |
| Activity Log | Week 6 | Track all changes within workspace |
| Offline Support | Week 7 | Work offline, sync when connection returns |
| Export Data | Week 8 | Export tasks to CSV or PDF |

---

## Tech Stack

**Presentation Layer:** Flutter UI with BLoC widgets

**State Management:** BLoC 8.x with Cubit and Equatable

**Business Logic:** Use cases with Repository Pattern

**Data Layer:** Firebase Auth and Cloud Firestore

**Core Dependencies:**

```yaml
flutter_bloc: ^8.1.3      # State management
firebase_auth: ^4.15.1    # Authentication
cloud_firestore: ^4.15.1  # Real-time database
get_it: ^7.6.4            # Dependency injection
equatable: ^2.0.5         # Value equality
intl: ^0.18.1             # Date formatting


Project Structure
text
lib/
├── core/                    # App-wide utilities
│   ├── themes/             # ThemeCubit (dark/light mode)
│   ├── constants/          # App constants
│   ├── utils/              # Helpers and extensions
│   └── widgets/            # Reusable UI components
│
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   │   ├── presentation/
│   │   │   ├── blocs/     # AuthBloc
│   │   │   └── screens/   # LoginScreen, RegisterScreen
│   │   └── data/          # FirebaseAuthDataSource
│   │
│   ├── workspace/          # Workspace
│   │   ├── presentation/
│   │   │   └── cubits/    # WorkspaceCubit
│   │   └── data/          # WorkspaceRepository
│   │
│   ├── projects/           # Projects
│   │   ├── presentation/
│   │   │   └── blocs/     # ProjectBloc
│   │   └── data/          # ProjectRepository
│   │
│   └── tasks/              # Tasks
│       ├── presentation/
│       │   └── blocs/     # TaskBloc
│       └── data/          # TaskRepository
│
├── data/                   # Data layer
│   ├── models/            # User, Project, Task models
│   ├── repositories/      # Abstract repository contracts
│   └── datasources/       # Firebase implementations
│
├── domain/                 # Business layer
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business use cases
│
└── main.dart              # App entry with dependency injection
Technical Learnings
BLoC Concepts Implemented
Concept	Implementation
Cubit (simple state)	ThemeCubit, WorkspaceCubit
Bloc with Events	AuthBloc, ProjectBloc, TaskBloc
BlocProvider / BlocBuilder	Throughout application
BlocListener	Navigation after authentication success
Real-time Streams	TaskBloc with Firestore listeners
Multiple BLoCs Communication	AuthBloc to WorkspaceCubit to ProjectBloc to TaskBloc
Form Validation	Login and register with validation states
Error Handling	Firebase exceptions mapped to UI error states
Repository Pattern	Abstract repositories with Firebase implementations
Dependency Injection	get_it for service locator pattern
Key Code Pattern – Real-time Streams with BLoC
dart
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;
  StreamSubscription? _subscription;

  void _onWatchTasks(WatchTasks event, Emitter<TaskState> emit) {
    _subscription = _repository.watchTasks().listen((tasks) {
      add(TasksUpdated(tasks));
    });
  }
}
Getting Started
Prerequisites
Flutter 3.x installed

Firebase project configured

Android or iOS emulator / physical device

Installation
bash
# 1. Clone the repository
git clone https://github.com/MuhammadFaraz032/task-manager.git
cd task-manager

# 2. Install dependencies
flutter pub get

# 3. Add Firebase configuration
# Android: Add google-services.json to android/app/
# iOS: Add GoogleService-Info.plist to ios/Runner/

# 4. Run the app
flutter run
Firebase Setup Requirements
Create a Firebase project

Enable Email and Password authentication

Create a Cloud Firestore database

Register your Android and/or iOS app with Firebase

Download and add configuration files as shown above

Testing
bash
# Run all tests
flutter test

# Run specific BLoC tests
flutter test test/blocs/task_bloc_test.dart
Test coverage includes AuthBloc state transitions, TaskBloc event handling, and repository mock implementations.

Progress Tracking
BLoC Learning Status
Concept	Status
BlocProvider / BlocBuilder	Complete
Cubit for simple state	Complete
Bloc with Events	Complete
Multiple States	Complete
BlocListener	Complete
BlocConsumer	Complete
Repository Pattern	Complete
Stream Integration (real-time)	Complete
bloc_test (unit testing)	In Progress
hydrated_bloc (state persistence)	Planned
Event Transformers	Planned
Feature Completion Status
Milestone	Status
MVP Complete	March 2026
Phase 2 – Collaboration Features	Planned
Phase 2 – Notifications	Planned
Phase 2 – Offline Support	Planned
Connect
Platform	Link
Portfolio	[Add your portfolio link here]
GitHub	https://github.com/MuhammadFaraz032
LinkedIn	[Add your LinkedIn URL here]
Acknowledgments
BLoC Library documentation and community

Firebase Flutter codelabs

Clean Architecture principles (adapted for Flutter)

Built with Flutter and BLoC – A portfolio project demonstrating real-world mobile development skills
