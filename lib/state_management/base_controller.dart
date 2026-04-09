import 'package:flutter/foundation.dart';

/// A base class for managing state in a [ChangeNotifier]-based architecture.
///
/// [StateController] holds a single state of type [T] and notifies its listeners
/// whenever the state changes. It is designed to be extended by more specific
/// controllers.
///
/// Example:
/// ```dart
/// class CounterController extends BaseController<int> {
///   CounterController() : super(0);
///
///   @override
///   void onInit() {}
///
///   void increment() => state = state + 1;
/// }
/// ```
base class StateController<T> extends ChangeNotifier {
  late T _state;

  /// The current state held by this controller.
  T get state => _state;

  /// Updates the state to [newState] and notifies listeners if the state has changed.
  ///
  /// Uses [identical] to compare the old and new state. If they are the same
  /// object, no notification is sent and the state is not updated.
  ///
  /// ```dart
  /// controller.state = newValue;
  /// ```
  set state(T newState) {
    if (_isSameState(newState)) return;
    _state = newState;
    notifyListeners();
  }

  /// Updates the state using an [update] function that receives the current state
  /// and returns a new state.
  ///
  /// Useful for deriving the next state from the current one without exposing
  /// mutable internals. No notification is sent if the returned state is
  /// identical to the current state.
  ///
  /// ```dart
  /// controller.updateState((current) => current.copyWith(count: current.count + 1));
  /// ```
  void updateState(T Function(T currentState) update) {
    final updated = update(_state);
    if (_isSameState(updated)) return;
    _state = updated;
    notifyListeners();
  }

  /// Returns true if [newState] is identical to the current [_state].
  ///
  /// Used internally to avoid unnecessary rebuilds and listener notifications.
  bool _isSameState(T newState) => identical(_state, newState);
}

/// An abstract base class for application-level controllers with lifecycle support.
///
/// [BaseController] extends [StateController] and adds an [onInit] lifecycle hook
/// that is called once during construction, allowing subclasses to perform
/// initialization logic (e.g., fetching data, setting up subscriptions).
///
/// Type parameter [T] represents the shape of the state managed by this controller.
///
/// Example:
/// ```dart
/// class UserController extends BaseController<UserState> {
///   UserController() : super(UserState.initial());
///
///   @override
///   void onInit() {
///     fetchCurrentUser();
///   }
///
///   Future<void> fetchCurrentUser() async {
///     final user = await userRepository.getUser();
///     state = UserState(user: user);
///   }
/// }
/// ```
abstract base class BaseController<T> extends StateController<T> {
  /// Creates a [BaseController] with the given [initialState].
  ///
  /// The [initialState] is assigned before [onInit] is called, so the state
  /// is already available when [onInit] executes.
  BaseController(T initialState) {
    _state = initialState;
    onInit();
  }

  /// Called once immediately after the controller is constructed and the
  /// initial state has been set.
  ///
  /// Override this method to perform any setup logic such as loading data,
  /// registering listeners, or initializing services.
  void onInit();
}
