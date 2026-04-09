# my_packages

A Flutter utility package providing two core building blocks for robust, scalable Flutter applications:

- **`Option<T>`** — a type-safe alternative to `null` for representing optional values.
- **`Result<T>`** — a type-safe alternative to `try/catch` for representing success or failure.
- **`BaseController` / `ControllerBuilder`** — a lightweight, `ChangeNotifier`-based state management solution.

---

## Features

### `Option<T>`
- Explicitly represent the presence (`Some`) or absence (`None`) of a value.
- Chainable API: `map`, `flatMap`, `fold`, `when`, `getOrElse`, and more.
- Eliminates ambiguous `null` checks across your codebase.

### `Result<T>`
- Represent an operation that can either succeed (`Success`) or fail (`Failure`).
- Carries the error and stack trace automatically on failure.
- Chainable API: `map`, `flatMap`, `mapError`, `fold`, `when`, `getOrElse`, and more.

### State Management
- `BaseController<T>` — extend to create a controller with a typed state and an `onInit` lifecycle hook.
- `ControllerBuilder<C, S>` — a widget that creates, owns, and disposes the controller, then rebuilds on state changes.
- `ControllerScope<C, S>` — an `InheritedNotifier` that exposes the controller to any descendant widget.
- Optional `listener` callback for side effects (navigation, snackbars, dialogs) without triggering a rebuild.

---

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  my_packages:
    path: ../my_packages  # adjust path as needed
```

Then import it:

```dart
import 'package:my_packages/my_packages.dart';
```

---

## Usage

### `Option<T>`

```dart
Option<String> findBio(User user) {
  return user.bio != null ? Option.some(user.bio!) : Option.none();
}

final bio = findBio(user).getOrElse('No bio available');

// Chaining
final upperBio = findBio(user)
    .map((b) => b.toUpperCase())
    .getOrElse('NO BIO');

// Pattern matching
findBio(user).when(
  some: (bio) => print('Bio: $bio'),
  none: () => print('No bio available'),
);
```

### `Result<T>`

```dart
Future<Result<User>> fetchUser(String id) async {
  try {
    final data = await api.get('/users/$id');
    return Result.ok(User.fromJson(data));
  } catch (e, st) {
    return Result.error(e, st);
  }
}

final result = await fetchUser('123');

// Get value with fallback
final user = result.getOrElse(User.guest());

// Chaining
final name = result
    .map((user) => user.name)
    .getOrElse('Unknown');

// Pattern matching
result.when(
  ok: (user) => print('Hello, ${user.name}'),
  error: (error, _) => print('Failed: $error'),
);
```

### State Management

**Define a controller:**

```dart
class CounterState {
  final int count;
  const CounterState({this.count = 0});
  CounterState copyWith({int? count}) => CounterState(count: count ?? this.count);
}

class CounterController extends BaseController<CounterState> {
  CounterController() : super(const CounterState());

  @override
  void onInit() {
    // Initialization logic (fetch data, subscribe to streams, etc.)
  }

  void increment() => updateState((s) => s.copyWith(count: s.count + 1));
  void decrement() => updateState((s) => s.copyWith(count: s.count - 1));
}
```

**Use in the widget tree:**

```dart
ControllerBuilder<CounterController, CounterState>(
  controllerFactory: () => CounterController(),
  listener: (state) {
    if (state.count == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reached 10!')),
      );
    }
  },
  builder: (context, state, controller) {
    return Column(
      children: [
        Text('Count: ${state.count}'),
        ElevatedButton(
          onPressed: controller.increment,
          child: const Text('+'),
        ),
      ],
    );
  },
);
```

**Access the controller from a descendant:**

```dart
final controller = ControllerScope.of<CounterController, CounterState>(context);
controller.increment();
```

---

## API Reference

### `Option<T>`

| Member | Description |
|---|---|
| `Option.some(value)` | Creates an `Option` containing `value`. |
| `Option.none()` | Creates an empty `Option`. |
| `isSome` | `true` if the option contains a value. |
| `isNone` | `true` if the option is empty. |
| `unwrap()` | Returns the value or throws if empty. |
| `getOrElse(default)` | Returns the value or `default`. |
| `getOrElseLazy(fn)` | Returns the value or calls `fn` for a default. |
| `getOrElseThrow(msg)` | Returns the value or throws with `msg`. |
| `map(fn)` | Transforms the value, propagates `None`. |
| `flatMap(fn)` | Chains `Option`-returning transforms. |
| `fold(onNone, onSome)` | Handles both cases, returns `R`. |
| `when({some, none})` | Side-effect handler for both cases. |

### `Result<T>`

| Member | Description |
|---|---|
| `Result.ok(value)` | Creates a successful `Result`. |
| `Result.error(error, [stackTrace])` | Creates a failed `Result`. |
| `isOk()` | `true` if the result is successful. |
| `isError()` | `true` if the result is a failure. |
| `getOrElse(default)` | Returns the value or `default`. |
| `getOrElseLazy(fn)` | Returns the value or calls `fn` for a default. |
| `getOrElseThrow()` | Returns the value or rethrows the original error. |
| `map(fn)` | Transforms the value, propagates `Failure`. |
| `flatMap(fn)` | Chains `Result`-returning transforms. |
| `mapError(fn)` | Transforms the error, preserves `Success`. |
| `fold({onError, onOk})` | Handles both cases, returns `R`. |
| `when({ok, error})` | Side-effect handler for both cases. |

### `BaseController<T>`

| Member | Description |
|---|---|
| `state` | The current state. |
| `state =` | Updates the state and notifies listeners. |
| `updateState(fn)` | Derives the next state from the current one. |
| `onInit()` | Lifecycle hook called once after construction. |

### `ControllerBuilder<C, S>`

| Parameter | Description |
|---|---|
| `controllerFactory` | Factory called once to create the controller. |
| `builder` | Rebuilds on every state change. |
| `listener` | Optional side-effect callback on state change. |

---

## Requirements

- Dart SDK `>=3.11.3`
- Flutter `>=1.17.0`
