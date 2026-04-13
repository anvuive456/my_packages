import 'package:flutter/foundation.dart';

import 'abstract_control.dart';

/// A function that validates a value of type [T].
///
/// Returns an error message string if invalid, or `null` if valid.
typedef Validator<T> = String? Function(T? value);

/// Holds a single typed value [T] with optional validation.
///
/// Extends [ChangeNotifier] so that [FormGroup] and [FormScope] can react
/// to value changes automatically.
///
/// ```dart
/// final username = FormControl<String>(
///   value: '',
///   validators: [Validators.required(), Validators.minLength(3)],
/// );
/// ```
class FormControl<T> extends ChangeNotifier implements AbstractControl<T?> {
  /// Creates a [FormControl] with an optional initial [value] and [validators].
  FormControl({T? value, this.validators = const []}) : _value = value;

  T? _value;

  /// The list of validators applied to this control's value.
  final List<Validator<T>> validators;

  bool _isDirty = false;
  bool _isTouched = false;

  @override
  T? get formValue => _value;

  /// Sets the value and marks the control as dirty.
  set value(T? v) {
    if (_value == v) return;
    _value = v;
    _isDirty = true;
    notifyListeners();
  }

  @override
  bool get isDirty => _isDirty;

  @override
  bool get isTouched => _isTouched;

  @override
  List<String> get errors =>
      validators.map((v) => v(_value)).whereType<String>().toList();

  @override
  bool get isValid => errors.isEmpty;

  /// Marks this control as touched (e.g. call on focus lost).
  void markAsTouched() {
    if (_isTouched) return;
    _isTouched = true;
    notifyListeners();
  }

  /// Resets the control to an optional [value], clearing dirty and touched state.
  void reset({T? value}) {
    _value = value;
    _isDirty = false;
    _isTouched = false;
    notifyListeners();
  }
}
