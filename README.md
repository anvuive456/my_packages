# my_packages

A Flutter utility package providing core building blocks for robust, scalable Flutter applications:

- **`Option<T>`** — a type-safe alternative to `null` for representing optional values.
- **`Result<T>`** — a type-safe alternative to `try/catch` for representing success or failure.
- **`BaseController` / `ControllerBuilder`** — a lightweight, `ChangeNotifier`-based state management solution.
- **Form Builder** — a reactive, type-safe form management system inspired by Reactive Forms, without the overhead.

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

### Form Builder
- `FormControl<T>` — holds a single typed value with optional validators.
- `TextFormControl` — extends `TextEditingController`, usable directly as a `TextField` controller.
- `FormGroup` — a named map of controls; supports dot-notation path access (`address.city`, `tags.0`).
- `FormArray<T>` — a dynamic list of controls; supports adding/removing at runtime.
- `FormBuilder` — a widget that binds a `FormGroup` to its subtree via `InheritedNotifier`, rebuilding on any change.
- `Validators` — built-in validators: `required`, `minLength`, `maxLength`, `pattern`, `email`, `compose`.

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

Use `ControllerBuilder.disposable` when the widget owns the controller lifecycle:

```dart
ControllerBuilder.disposable<CounterController, CounterState>(
  controllerFactory: CounterController.new,
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

Use the default constructor when the controller is managed externally (e.g. via `get_it`):

```dart
ControllerBuilder<CounterController, CounterState>(
  controllerFactory: () => getIt<CounterController>(),
  builder: (context, state, controller) => Text('Count: ${state.count}'),
);
```

**Access the controller from a descendant:**

```dart
final controller = ControllerScope.of<CounterController, CounterState>(context);
controller.increment();
```

### Form Builder

**Define a form outside the widget (in `State` or your state management layer):**

```dart
final form = FormGroup({
  'username': TextFormControl(
    value: '',
    validators: [Validators.required(), Validators.minLength(3)],
  ),
  'email': TextFormControl(
    value: '',
    validators: [Validators.required(), Validators.email()],
  ),
  'age': FormControl<int>(validators: [Validators.required()]),
  'address': FormGroup({
    'city': TextFormControl(value: ''),
  }),
  'tags': FormArray<String>([
    TextFormControl(value: 'flutter'),
  ]),
});
```

**Bind to the widget tree with `FormBuilder`:**

```dart
FormBuilder(
  form: form,
  builder: (context, form) => Column(children: [
    // TextFormControl used directly as a TextField controller — no onChanged needed
    TextField(controller: form.text('username')),

    // Nested FormGroup via dot-notation
    TextField(controller: form.text('address.city')),

    // Validation errors
    if (form.text('email').isTouched)
      Text(form.text('email').errors.join(', ')),

    ElevatedButton(
      onPressed: form.isValid ? _submit : null,
      child: const Text('Submit'),
    ),
  ]),
)
```

**Dynamic lists with `FormArray`:**

```dart
FormBuilder(
  form: form,
  builder: (context, form) {
    final todos = form.array('todos');
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, i) {
        final todo = todos.groupAt(i);
        // Nest FormBuilder per item — each item rebuilds independently
        return FormBuilder(
          form: todo,
          builder: (context, form) => ListTile(
            leading: Checkbox(
              value: form.get<bool>('done'),
              onChanged: (v) => form.set('done', v == true),
            ),
            title: TextField(controller: form.text('title')),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => todos.removeAt(i),
            ),
          ),
        );
      },
    );
  },
)
```

**Reset the entire form:**

```dart
form.reset();  // clears all values, dirty, and touched state
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

| Constructor | Description |
|---|---|
| `ControllerBuilder(...)` | Accepts an external controller — does **not** dispose it. Use with DI containers. |
| `ControllerBuilder.disposable(...)` | Creates and owns the controller — disposes it when removed from the tree. |

| Parameter | Description |
|---|---|
| `controllerFactory` | Factory called once to create the controller. |
| `builder` | Rebuilds on every state change. |
| `listener` | Optional side-effect callback on state change. |

### Form Builder

#### `AbstractControl<T>`

| Member | Description |
|---|---|
| `formValue` | The typed form value of this control. |
| `isValid` | `true` if all validators pass. |
| `isDirty` | `true` if the value has changed since init/reset. |
| `isTouched` | `true` if `markAsTouched()` has been called. |
| `errors` | List of validation error messages. |
| `reset()` | Resets value, dirty, and touched state. |

#### `FormControl<T>`

| Member | Description |
|---|---|
| `FormControl({value, validators})` | Creates a typed control. |
| `formValue` | Current value as `T?`. |
| `value =` | Sets the value, marks dirty, notifies listeners. |
| `markAsTouched()` | Marks the control as touched. |
| `reset({value})` | Resets to optional value, clears dirty/touched. |

#### `TextFormControl`

Extends `TextEditingController` — pass directly as `controller` to `TextField` or `TextFormField`. No `onChanged` needed.

| Member | Description |
|---|---|
| `TextFormControl({value, validators})` | Creates a text control. |
| `formValue` | Current text as `String`. |
| `markAsTouched()` | Marks the control as touched. |
| `reset()` | Clears text, dirty, and touched state. |

#### `FormGroup`

| Member | Description |
|---|---|
| `FormGroup(controls)` | Creates a group from a named map of controls. |
| `get<T>(path)` | Reads a value by dot-notation path. |
| `set<T>(path, value)` | Writes a value by dot-notation path. |
| `control(name)` | Returns a direct child `AbstractControl`. |
| `text(name)` | Returns a direct child `TextFormControl`. |
| `group(name)` | Returns a direct child `FormGroup`. |
| `array(name)` | Returns a direct child `FormArray`. |
| `form<T>(name)` | Returns a direct child `FormControl<T>`. |
| `formValue` | Snapshot of all values as `Map<String, dynamic>`. |
| `isValid` | `true` if all descendant controls are valid. |
| `reset()` | Resets all descendant controls. |

#### `FormArray<T>`

| Member | Description |
|---|---|
| `FormArray(controls)` | Creates an array from an initial list. |
| `length` | Number of controls. |
| `getAt(index)` | Returns the value at `index` as `T?`. |
| `groupAt(index)` | Returns the `FormGroup` at `index`. |
| `controlAt(index)` | Returns the `AbstractControl` at `index`. |
| `add(control)` | Appends a control and notifies listeners. |
| `removeAt(index)` | Removes a control and notifies listeners. |
| `reset()` | Resets all controls. |

#### `FormBuilder`

| Parameter | Description |
|---|---|
| `form` | The `FormGroup` to bind. |
| `builder` | Called with `(context, FormGroup)` on every change. |

#### `Validators`

| Validator | Description |
|---|---|
| `Validators.required()` | Fails if value is `null` or empty string. |
| `Validators.minLength(n)` | Fails if string length < `n`. |
| `Validators.maxLength(n)` | Fails if string length > `n`. |
| `Validators.pattern(regex)` | Fails if string does not match `regex`. |
| `Validators.email()` | Fails if string is not a valid email. |
| `Validators.compose(validators)` | Runs validators in order, returns first error. |

---

## Requirements

- Dart SDK `>=3.11.3`
- Flutter `>=1.17.0`
