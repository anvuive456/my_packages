import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_packages/base/base.dart';
import 'package:my_packages/storage/storage.dart';

/// A [Storage] implementation backed by [FlutterSecureStorage].
///
/// Subclasses must implement [Serializable] to define how [T] is encoded
/// to and decoded from a [String].
///
/// An optional [FlutterSecureStorage] instance can be injected via the
/// constructor — primarily useful for testing.
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
abstract class SecureStorage<T> extends Storage<T>
    implements Serializable<T, String> {
  /// Creates a secure storage instance scoped to [key].
  ///
  /// Pass a custom [storage] to override the default [FlutterSecureStorage],
  /// e.g. a fake in tests.
  SecureStorage(super.key, [FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<Option<T>> read() async {
    final result = await _storage.read(key: key);
    if (result == null || result.isEmpty) return None<T>();
    return parse(result);
  }

  @override
  Future<Result<bool>> write(T value) async {
    try {
      final encoded = serialize(value);
      if (encoded.isNone) return Failure(Exception('Cannot serialize value'));
      await _storage.write(key: key, value: encoded.unwrap());
      return Success(true);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<bool>> delete() async {
    try {
      await _storage.delete(key: key);
      return Success(true);
    } catch (e) {
      return Failure(e);
    }
  }
}
