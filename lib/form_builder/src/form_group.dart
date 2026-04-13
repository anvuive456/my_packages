import 'package:flutter/foundation.dart';

import 'abstract_control.dart';
import 'form_array.dart';
import 'form_control.dart';
import 'text_form_control.dart';

/// A group of named [AbstractControl]s, acting as a composite control.
///
/// Extends [ChangeNotifier] and propagates change notifications from all
/// child controls upward, allowing [FormScope] to rebuild the widget tree
/// whenever any nested value changes.
///
/// ```dart
/// final form = FormGroup({
///   'username': FormControl<String>(value: ''),
///   'address': FormGroup({
///     'city': FormControl<String>(value: ''),
///   }),
/// });
/// ```
class FormGroup extends ChangeNotifier
    implements AbstractControl<Map<String, dynamic>> {
  /// Creates a [FormGroup] from a map of named controls.
  FormGroup(Map<String, AbstractControl> controls)
    : _controls = Map.unmodifiable(controls) {
    for (final c in _controls.values) {
      if (c is ChangeNotifier) {
        (c as ChangeNotifier).addListener(notifyListeners);
      }
    }
  }

  final Map<String, AbstractControl> _controls;

  /// Returns the value at [path], supporting dot notation.
  ///
  /// Examples:
  /// ```dart
  /// form.get<String>('username')
  /// form.get<String>('address.city')   // nested FormGroup
  /// form.get<String>('tags.0')         // FormArray index
  /// form.get<String>('tags.0.label')   // FormArray then nested FormGroup
  /// ```
  T get<T>(String path) {
    final dotIndex = path.indexOf('.');

    if (dotIndex == -1) {
      final control = _controls[path];
      if (control == null) throw ArgumentError('Control "$path" not found');
      return control.formValue as T;
    }

    final key = path.substring(0, dotIndex);
    final rest = path.substring(dotIndex + 1);
    final child = _controls[key];

    if (child is FormGroup) return child.get<T>(rest);
    if (child is FormArray) return child.getByPath<T>(rest);

    throw ArgumentError('Cannot navigate path: "$path"');
  }

  /// Sets the value at [path], supporting dot notation.
  ///
  /// Examples:
  /// ```dart
  /// form.set('username', 'alice');
  /// form.set('address.city', 'Hanoi');
  /// form.set('tags.0', 'flutter');
  /// ```
  void set<T>(String path, T value) {
    final dotIndex = path.indexOf('.');

    if (dotIndex == -1) {
      final control = _controls[path];
      if (control is FormControl<T>) {
        control.value = value;
        return;
      }
      // Fallback for dynamic typing (e.g. FormControl<String> passed as T=dynamic)
      if (control is FormControl) {
        (control as dynamic).value = value;
        return;
      }
      if (control is TextFormControl) {
        control.text = value as String? ?? '';
        return;
      }
      throw ArgumentError('Control "$path" is not settable');
    }

    final key = path.substring(0, dotIndex);
    final rest = path.substring(dotIndex + 1);
    final child = _controls[key];

    if (child is FormGroup) {
      child.set<T>(rest, value);
      return;
    }
    if (child is FormArray) {
      child.setByPath<T>(rest, value);
      return;
    }

    throw ArgumentError('Cannot navigate path: "$path"');
  }

  /// Returns the direct child control at [name] (no dot notation).
  AbstractControl control(String name) {
    final c = _controls[name];
    if (c == null) throw ArgumentError('Control "$name" not found');
    return c;
  }

  /// Returns the [FormArray] child at [name].
  ///
  /// Throws if the control is not a [FormArray].
  FormArray array(String name) {
    final c = control(name);
    if (c is! FormArray) {
      throw ArgumentError('Control "$name" is not a FormArray');
    }
    return c;
  }

  /// Returns the [FormGroup] child at [name].
  ///
  /// Throws if the control is not a [FormGroup].
  FormGroup group(String name) {
    final c = control(name);
    if (c is! FormGroup) {
      throw ArgumentError('Control "$name" is not a FormGroup');
    }
    return c;
  }

  /// Returns the [FormControl] child at [name] with a [String] value.
  ///
  /// Throws if the control is not a [FormControl<String>].
  FormControl<T> form<T>(String s) {
    final c = control(s);
    if (c is! FormControl<T>) {
      throw ArgumentError('Control "$s" is not a FormControl<$T>');
    }
    return c;
  }

  /// Returns the [TextFormControl] child at [name].
  ///
  /// Throws if the control is not a [TextFormControl].
  TextFormControl text(String name) {
    final c = control(name);
    if (c is! TextFormControl) {
      throw ArgumentError('Control "$name" is not a TextFormControl');
    }
    return c;
  }

  @override
  /// Resets all child controls to their initial values.
  void reset() {
    for (final c in _controls.values) {
      c.reset();
    }
  }

  @override
  Map<String, dynamic> get formValue => {
    for (final e in _controls.entries) e.key: e.value.formValue,
  };

  @override
  bool get isValid => _controls.values.every((c) => c.isValid);

  @override
  bool get isDirty => _controls.values.any((c) => c.isDirty);

  @override
  bool get isTouched => _controls.values.any((c) => c.isTouched);

  @override
  List<String> get errors => _controls.values.expand((c) => c.errors).toList();

  @override
  void dispose() {
    for (final c in _controls.values) {
      if (c is ChangeNotifier) {
        (c as ChangeNotifier).removeListener(notifyListeners);
        (c as ChangeNotifier).dispose();
      }
    }
    super.dispose();
  }
}
