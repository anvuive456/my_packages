import 'package:my_packages/base/base.dart';
import 'package:my_packages/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base class for [Storage] implementations backed by [SharedPreferences].
///
/// Subclasses pick a native [SharedPreferences] type [S] by extending one of
/// the provided typed variants:
///
/// | Extend                       | Native type       |
/// |------------------------------|-------------------|
/// | [StringPrefsStorage]         | `String`          |
/// | [IntPrefsStorage]            | `int`             |
/// | [DoublePrefsStorage]         | `double`          |
/// | [BoolPrefsStorage]           | `bool`            |
/// | [StringListPrefsStorage]     | `List<String>`    |
///
/// Each subclass must then implement [Serializable] to convert between [T]
/// and the chosen native type [S].
///
/// An optional [SharedPreferences] instance can be injected — primarily
/// useful for testing.
abstract class SharedPreferencesStorage<T, S> extends Storage<T>
    implements Serializable<T, S> {
  SharedPreferencesStorage(super.key, [SharedPreferences? prefs])
    : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  S? _readRaw(SharedPreferences prefs);
  Future<void> _writeRaw(SharedPreferences prefs, S value);

  @override
  Future<Option<T>> read() async {
    final prefs = await _getPrefs();
    final result = _readRaw(prefs);
    if (result == null) return None<T>();
    return parse(result);
  }

  @override
  Future<Result<bool>> write(T value) async {
    try {
      final encoded = serialize(value);
      if (encoded.isNone) return Failure(Exception('Cannot serialize value'));
      final prefs = await _getPrefs();
      await _writeRaw(prefs, encoded.unwrap());
      return Success(true);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<bool>> delete() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(key);
      return Success(true);
    } catch (e) {
      return Failure(e);
    }
  }
}

/// A [SharedPreferencesStorage] that stores values as [String].
///
/// Example:
/// ```dart
/// class ThemeStorage extends StringPrefsStorage<ThemeMode> {
///   ThemeStorage() : super('theme');
///
///   @override
///   Option<String> serialize(ThemeMode value) => Some(value.name);
///
///   @override
///   Option<ThemeMode> parse(String value) =>
///       Some(ThemeMode.values.byName(value));
/// }
/// ```
abstract class StringPrefsStorage<T>
    extends SharedPreferencesStorage<T, String> {
  StringPrefsStorage(super.key, [super.prefs]);

  @override
  String? _readRaw(SharedPreferences prefs) => prefs.getString(key);

  @override
  Future<void> _writeRaw(SharedPreferences prefs, String value) =>
      prefs.setString(key, value);
}

/// A [SharedPreferencesStorage] that stores values as [int].
///
/// Example:
/// ```dart
/// class BadgeCountStorage extends IntPrefsStorage<int> {
///   BadgeCountStorage() : super('badge_count');
///
///   @override
///   Option<int> serialize(int value) => Some(value);
///
///   @override
///   Option<int> parse(int value) => Some(value);
/// }
/// ```
abstract class IntPrefsStorage<T> extends SharedPreferencesStorage<T, int> {
  IntPrefsStorage(super.key, [super.prefs]);

  @override
  int? _readRaw(SharedPreferences prefs) => prefs.getInt(key);

  @override
  Future<void> _writeRaw(SharedPreferences prefs, int value) =>
      prefs.setInt(key, value);
}

/// A [SharedPreferencesStorage] that stores values as [double].
///
/// Example:
/// ```dart
/// class FontSizeStorage extends DoublePrefsStorage<double> {
///   FontSizeStorage() : super('font_size');
///
///   @override
///   Option<double> serialize(double value) => Some(value);
///
///   @override
///   Option<double> parse(double value) => Some(value);
/// }
/// ```
abstract class DoublePrefsStorage<T>
    extends SharedPreferencesStorage<T, double> {
  DoublePrefsStorage(super.key, [super.prefs]);

  @override
  double? _readRaw(SharedPreferences prefs) => prefs.getDouble(key);

  @override
  Future<void> _writeRaw(SharedPreferences prefs, double value) =>
      prefs.setDouble(key, value);
}

/// A [SharedPreferencesStorage] that stores values as [bool].
///
/// Example:
/// ```dart
/// class OnboardingStorage extends BoolPrefsStorage<bool> {
///   OnboardingStorage() : super('onboarding_done');
///
///   @override
///   Option<bool> serialize(bool value) => Some(value);
///
///   @override
///   Option<bool> parse(bool value) => Some(value);
/// }
/// ```
abstract class BoolPrefsStorage<T> extends SharedPreferencesStorage<T, bool> {
  BoolPrefsStorage(super.key, [super.prefs]);

  @override
  bool? _readRaw(SharedPreferences prefs) => prefs.getBool(key);

  @override
  Future<void> _writeRaw(SharedPreferences prefs, bool value) =>
      prefs.setBool(key, value);
}

/// A [SharedPreferencesStorage] that stores values as [List<String>].
///
/// Example:
/// ```dart
/// class RecentSearchStorage extends StringListPrefsStorage<List<String>> {
///   RecentSearchStorage() : super('recent_searches');
///
///   @override
///   Option<List<String>> serialize(List<String> value) => Some(value);
///
///   @override
///   Option<List<String>> parse(List<String> value) => Some(value);
/// }
/// ```
abstract class StringListPrefsStorage<T>
    extends SharedPreferencesStorage<T, List<String>> {
  StringListPrefsStorage(super.key, [super.prefs]);

  @override
  List<String>? _readRaw(SharedPreferences prefs) => prefs.getStringList(key);

  @override
  Future<void> _writeRaw(SharedPreferences prefs, List<String> value) =>
      prefs.setStringList(key, value);
}
