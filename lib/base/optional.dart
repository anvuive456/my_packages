/// A data type that represents a value that may or may not be present.
/// Replaces null to be more explicit about handling absent values.
///
/// Example:
/// ```dart
/// class User {
///   final String name;
///   final Option<String> bio; // bio may not be present
///
///   User(this.name, {this.bio = const None()});
/// }
///
/// final user = User('An', bio: Option.some('Developer'));
/// print(user.bio.getOrElse('No bio available')); // -> Developer
///
/// final user2 = User('Binh');
/// print(user2.bio.getOrElse('No bio available')); // -> No bio available
/// ```
sealed class Option<T> {
  const Option._();

  /// Creates an Option containing [value].
  ///
  /// ```dart
  /// final name = Option.some('An'); // Some(An)
  /// ```
  factory Option.some(T value) = Some<T>;

  /// Creates an empty Option with no value.
  ///
  /// ```dart
  /// final name = Option<String>.none(); // None
  /// ```
  const factory Option.none() = None;

  /// Returns an Option containing the given [value], or [None] if [value] is null.
  ///
  /// ```dart
  /// Option.fromNullable('An'); // Some(An)
  /// Option.fromNullable(null); // None
  /// ```
  factory Option.fromNullable(T? value) => value == null ? None() : Some(value);

  /// Returns true if this Option contains a value.
  ///
  /// ```dart
  /// Option.some('An').isSome; // true
  /// Option<String>.none().isSome; // false
  /// ```
  bool get isSome => this is Some<T>;

  /// Returns true if this Option is empty.
  ///
  /// ```dart
  /// Option<String>.none().isNone; // true
  /// Option.some('An').isNone; // false
  /// ```
  bool get isNone => this is None<T>;

  /// Returns the inner value, or throws an exception if empty.
  ///
  /// ```dart
  /// Option.some('An').unwrap(); // -> An
  /// Option<String>.none().unwrap(); // -> Exception: Option is None
  /// ```
  T unwrap() => switch (this) {
    Some(:final value) => value,
    None() => throw Exception('Option is None'),
  };

  /// Returns the inner value, or [defaultValue] if empty.
  ///
  /// ```dart
  /// Option.some('An').getOrElse('Anonymous'); // -> An
  /// Option<String>.none().getOrElse('Anonymous'); // -> Anonymous
  /// ```
  T getOrElse(T defaultValue) => switch (this) {
    Some(:final value) => value,
    None() => defaultValue,
  };

  /// Returns the inner value, or calls [defaultValue] to produce a fallback.
  /// Useful when the default value is expensive to compute.
  ///
  /// ```dart
  /// Option<List<int>>.none().getOrElseLazy(() => List.generate(1000, (i) => i));
  /// ```
  T getOrElseLazy(T Function() defaultValue) => switch (this) {
    Some(:final value) => value,
    None() => defaultValue(),
  };

  /// Returns the inner value, or throws an Exception with [exceptionMessage] if empty.
  ///
  /// ```dart
  /// final user = findUser(id).getOrElseThrow('User not found');
  /// ```
  T getOrElseThrow(String exceptionMessage) => switch (this) {
    Some(:final value) => value,
    None() => throw Exception(exceptionMessage),
  };

  /// Returns the inner value, or calls [exceptionMessage] to produce an error message and throws.
  ///
  /// ```dart
  /// final user = findUser(id).getOrElseThrowLazy(
  ///   () => 'User not found with id: $id',
  /// );
  /// ```
  T getOrElseThrowLazy(String Function() exceptionMessage) => switch (this) {
    Some(:final value) => value,
    None() => throw Exception(exceptionMessage()),
  };

  /// Transforms the inner value to another type.
  /// Returns None if this Option is empty.
  ///
  /// ```dart
  /// Option.some('an').map((s) => s.toUpperCase()); // Some(AN)
  /// Option<String>.none().map((s) => s.toUpperCase()); // None
  /// ```
  Option<R> map<R>(R Function(T value) f) => switch (this) {
    Some(:final value) => Some(f(value)),
    None() => const None(),
  };

  /// Transforms the inner value into another Option, used for chaining Options.
  /// Avoids nested Options (`Option<Option<T>>`).
  ///
  /// ```dart
  /// Option.some('2024-01-01').flatMap((s) {
  ///   final dt = DateTime.tryParse(s);
  ///   return dt != null ? Option.some(dt) : Option.none();
  /// }); // Some(2024-01-01 00:00:00.000)
  /// ```
  Option<R> flatMap<R>(Option<R> Function(T value) f) => switch (this) {
    Some(:final value) => f(value),
    None() => const None(),
  };

  /// Handles both Some and None cases, returning a value of type [R].
  ///
  /// ```dart
  /// final label = user.bio.fold(
  ///   () => 'No bio available',
  ///   (bio) => 'Bio: $bio',
  /// ); // -> Bio: Developer
  /// ```
  R fold<R>(R Function() onNone, R Function(T value) onSome) => switch (this) {
    Some(:final value) => onSome(value),
    None() => onNone(),
  };

  /// Performs a side effect depending on whether the Option is Some or None.
  /// Does not return a value.
  ///
  /// ```dart
  /// user.bio.when(
  ///   some: (bio) => print('Bio: $bio'),
  ///   none: () => print('No bio available'),
  /// );
  /// ```
  void when({void Function(T value)? some, void Function()? none}) =>
      switch (this) {
        Some(:final value) => some?.call(value),
        None() => none?.call(),
      };
}

/// An Option that contains a value.
class Some<T> extends Option<T> {
  /// The value wrapped by this [Some] instance.
  final T value;

  /// Creates a [Some] wrapping the given [value].
  const Some(this.value) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Some<T> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Some($value)';
}

/// An empty Option with no value.
class None<T> extends Option<T> {
  /// Creates a [None] instance.
  const None() : super._();

  @override
  bool operator ==(Object other) => identical(this, other) || other is None;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None';
}
