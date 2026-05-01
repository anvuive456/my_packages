import 'package:my_packages/base/base.dart';

/// A storage-backend-agnostic interface for persisting a single value of type [T].
///
/// Subclasses choose their own storage backend (e.g. secure storage,
/// shared preferences, in-memory) by implementing [read], [write], and [delete].
///
/// Each instance is scoped to one [key], which identifies where the value
/// is stored in the underlying backend.
///
/// Example:
/// ```dart
/// class TokenStorage extends SecureStorage<String> {
///   TokenStorage() : super('auth_token');
///
///   @override
///   Option<String> serialize(String value) => Some(value);
///
///   @override
///   Option<String> parse(String value) => Some(value);
/// }
/// ```
abstract class Storage<T> {
  /// Creates a storage instance scoped to [key].
  Storage(this.key);

  /// The key that identifies this value in the underlying backend.
  final String key;

  /// Returns the stored value, or [None] if absent or unreadable.
  Future<Option<T>> read();

  /// Persists [value] to the underlying backend.
  ///
  /// Returns [Success(true)] on success, [Success(false)] if the value could
  /// not be serialized, and [Failure] if the backend throws.
  Future<Result<bool>> write(T value);

  /// Removes the stored value from the underlying backend.
  ///
  /// Returns [Success(true)] on success, [Failure] if the backend throws.
  Future<Result<bool>> delete();
}
