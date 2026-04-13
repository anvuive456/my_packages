import 'form_control.dart';

/// A collection of common built-in [Validator] factories.
abstract class Validators {
  /// Fails if the value is `null` or an empty string.
  static Validator<T> required<T>({String message = 'This field is required'}) {
    return (value) {
      if (value == null) return message;
      if (value is String && value.isEmpty) return message;
      return null;
    };
  }

  /// Fails if the string length is less than [min].
  static Validator<String> minLength(int min, {String? message}) {
    return (value) {
      if (value == null || value.length < min) {
        return message ?? 'Minimum length is $min';
      }
      return null;
    };
  }

  /// Fails if the string length exceeds [max].
  static Validator<String> maxLength(int max, {String? message}) {
    return (value) {
      if (value != null && value.length > max) {
        return message ?? 'Maximum length is $max';
      }
      return null;
    };
  }

  /// Fails if the value does not match [regex].
  static Validator<String> pattern(Pattern regex, {String? message}) {
    return (value) {
      if (value == null || regex.allMatches(value).isEmpty) {
        return message ?? 'Invalid format';
      }
      return null;
    };
  }

  /// Runs [validators] in order and returns the first error found.
  static Validator<T> compose<T>(List<Validator<T>> validators) {
    return (value) {
      for (final v in validators) {
        final error = v(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Fails if the value is not a valid email address.
  static Validator<String> email({String message = 'Invalid email'}) {
    return (value) {
      final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

      if (value == null || !regex.hasMatch(value)) {
        return message;
      }
      return null;
    };
  }
}
