import 'package:my_packages/base/base.dart';

/// A contract for types that can be serialized to [S] and deserialized back to [T].
///
/// [T] is the domain type. [S] is the serialized form (e.g. [String], [Map]).
///
/// Example:
/// ```dart
/// class UserStorage extends SecureStorage<User> implements Serializable<User, String> {
///   UserStorage() : super('user');
///
///   @override
///   Option<String> serialize(User value) => Some(jsonEncode(value.toJson()));
///
///   @override
///   Option<User> parse(String value) {
///     try {
///       return Some(User.fromJson(jsonDecode(value)));
///     } catch (_) {
///       return None();
///     }
///   }
/// }
/// ```
abstract interface class Serializable<T, S> {
  /// Encodes [value] into its serialized form.
  ///
  /// Return [None] to signal that [value] cannot be serialized.
  Option<S> serialize(T value);

  /// Decodes [value] back into a [T].
  ///
  /// Return [None] if [value] is invalid or unrecognized.
  Option<T> parse(S value);
}
