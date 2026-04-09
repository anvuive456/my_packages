/// A data type representing the result of an operation that can either succeed or fail.
/// Replaces try/catch for explicit and type-safe error handling.
///
/// Example:
/// ```dart
/// Future<Result<LoginResponse>> login(LoginRequest request) async {
///   final result = await apiClient.post('/api/auth/login', data: request.toJson());
///   return result.map(LoginResponse.fromReader);
/// }
///
/// // Usage:
/// final result = await authRepository.login(request);
/// result.when(
///   ok: (response) => print('Login successful: ${response.user}'),
///   error: (error, _) => print('Login failed: $error'),
/// );
/// ```
sealed class Result<T> {
  const Result._();

  /// Creates a successful Result with [value].
  ///
  /// ```dart
  /// final result = Result.ok(42); // Success(42)
  /// ```
  factory Result.ok(T value) = Success<T>;

  /// Creates a failed Result with [error].
  /// [stackTrace] defaults to StackTrace.current if not provided.
  ///
  /// ```dart
  /// final result = Result.error(Exception('Connection error'));
  /// final result2 = Result.error(Exception('Error'), customStackTrace);
  /// ```
  factory Result.error(Object error, [StackTrace? stackTrace]) = Failure<T>;

  /// Returns true if the Result is successful.
  ///
  /// ```dart
  /// Result.ok(42).isOk(); // true
  /// Result.error(Exception('Error')).isOk(); // false
  /// ```
  bool isOk() => this is Success<T>;

  /// Returns true if the Result is a failure.
  ///
  /// ```dart
  /// Result.error(Exception('Error')).isError(); // true
  /// Result.ok(42).isError(); // false
  /// ```
  bool isError() => this is Failure<T>;

  /// Returns the inner value, or [defaultValue] if the Result is a failure.
  ///
  /// ```dart
  /// Result.ok(42).getOrElse(0); // -> 42
  /// Result<int>.error(Exception('Error')).getOrElse(0); // -> 0
  /// ```
  T getOrElse(T defaultValue) => switch (this) {
    Success(:final value) => value,
    Failure() => defaultValue,
  };

  /// Returns the inner value, or calls [defaultValue] to produce a fallback if the Result is a failure.
  ///
  /// ```dart
  /// Result<int>.error(Exception('Error')).getOrElseLazy(() => computeExpensiveValue());
  /// ```
  T getOrElseLazy(T Function() defaultValue) => switch (this) {
    Success(:final value) => value,
    Failure() => defaultValue(),
  };

  /// Returns the inner value, or rethrows the original error if the Result is a failure.
  ///
  /// ```dart
  /// final value = Result.ok(42).getOrElseThrow(); // -> 42
  /// Result.error(Exception('Error')).getOrElseThrow(); // throws Exception('Error')
  /// ```
  T getOrElseThrow() => switch (this) {
    Success(:final value) => value,
    Failure(:final error) => throw error,
  };

  /// Transforms the successful value into another type.
  /// If the Result is a failure, the error is preserved as-is.
  ///
  /// See also [flatMap] for when the transform itself returns a `Result`.
  ///
  /// ```dart
  /// Result.ok(42).map((v) => v * 2); // Success(84)
  /// Result<int>.error(Exception('Error')).map((v) => v * 2); // Failure(Error)
  /// ```
  Result<R> map<R>(R Function(T value) f) => switch (this) {
    Success(:final value) => Success(f(value)),
    Failure(:final error, :final stackTrace) => Failure(error, stackTrace),
  };

  /// Transforms the successful value into another Result, used for chaining operations.
  /// Avoids nested Results (`Result<Result<T>>`).
  ///
  /// ```dart
  /// fetchUser(id).flatMap((user) => fetchProfile(user.profileId));
  /// // If fetchUser fails -> returns Failure
  /// // If fetchUser succeeds -> calls fetchProfile
  /// ```
  Result<R> flatMap<R>(Result<R> Function(T value) f) => switch (this) {
    Success(:final value) => f(value),
    Failure(:final error, :final stackTrace) => Failure(error, stackTrace),
  };

  /// Transforms the error into another error, while preserving the successful value.
  ///
  /// ```dart
  /// result.mapError((error) => AppException('App error: $error'));
  /// ```
  Result<T> mapError(Object Function(Object error) f) => switch (this) {
    Success() => this,
    Failure(:final error, :final stackTrace) => Failure(f(error), stackTrace),
  };

  /// Handles both success and failure cases and returns a value of type [R].
  ///
  /// ```dart
  /// final message = result.fold(
  ///   onError: (error, stackTrace) => 'Error: $error',
  ///   onOk: (value) => 'Success: $value',
  /// );
  /// ```
  R fold<R>({
    required R Function(Object error, StackTrace stackTrace) onError,
    required R Function(T value) onOk,
  }) => switch (this) {
    Success(:final value) => onOk(value),
    Failure(:final error, :final stackTrace) => onError(error, stackTrace),
  };

  /// Performs a side effect depending on whether the Result is a success or failure.
  /// Does not return a value.
  ///
  /// ```dart
  /// result.when(
  ///   ok: (value) => print('Value: $value'),
  ///   error: (error, _) => print('Error: $error'),
  /// );
  /// ```
  void when({
    void Function(T value)? ok,
    void Function(Object error, StackTrace stackTrace)? error,
  }) => switch (this) {
    Success(:final value) => ok?.call(value),
    Failure(error: final err, stackTrace: final st) => error?.call(err, st),
  };
}

/// A successful Result containing a value.
class Success<T> extends Result<T> {
  /// The value produced by the successful operation.
  final T value;

  /// Creates a [Success] wrapping [value].
  const Success(this.value) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// A failed Result containing an error and stackTrace.
class Failure<T> extends Result<T> {
  /// The error that caused the failure.
  final Object error;

  /// The stack trace captured at the point of failure.
  ///
  /// Defaults to [StackTrace.current] at construction time if not provided.
  late StackTrace stackTrace;

  /// Creates a [Failure] with the given [error] and an optional [stackTrace].
  ///
  /// If [stackTrace] is omitted, [StackTrace.current] is captured automatically.
  Failure(this.error, [StackTrace? stackTrace]) : super._() {
    this.stackTrace = stackTrace ?? StackTrace.current;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          error == other.error &&
          stackTrace == other.stackTrace;

  @override
  int get hashCode => Object.hash(error, stackTrace);

  @override
  String toString() => 'Failure($error, $stackTrace)';
}
