import 'package:flutter/foundation.dart';

import 'abstract_control.dart';
import 'form_control.dart';
import 'form_group.dart';

/// A list of [AbstractControl]s, acting as a dynamic collection control.
///
/// Supports adding and removing controls at runtime. Propagates change
/// notifications from all child controls upward.
///
/// ```dart
/// final tags = FormArray<String>([
///   FormControl<String>(value: 'flutter'),
///   FormControl<String>(value: 'dart'),
/// ]);
/// ```
class FormArray<T> extends ChangeNotifier implements AbstractControl<List<T?>> {
  /// Creates a [FormArray] from an initial list of controls.
  FormArray(List<AbstractControl> controls) : _controls = List.of(controls) {
    for (final c in _controls) {
      if (c is ChangeNotifier) (c as ChangeNotifier).addListener(notifyListeners);
    }
  }

  final List<AbstractControl> _controls;

  /// The number of controls in this array.
  int get length => _controls.length;

  /// Returns the control at [index].
  AbstractControl controlAt(int index) => _controls[index];

  /// Returns the [FormGroup] at [index].
  ///
  /// Throws if the control at [index] is not a [FormGroup].
  FormGroup groupAt(int index) {
    final c = _controls[index];
    if (c is! FormGroup) throw ArgumentError('Control at index $index is not a FormGroup');
    return c;
  }

  /// Returns the value at [index] cast to [T].
  T? getAt(int index) => _controls[index].formValue as T?;

  /// Appends [control] to the array.
  void add(AbstractControl control) {
    _controls.add(control);
    if (control is ChangeNotifier) (control as ChangeNotifier).addListener(notifyListeners);
    notifyListeners();
  }

  /// Removes the control at [index].
  void removeAt(int index) {
    final control = _controls.removeAt(index);
    if (control is ChangeNotifier) (control as ChangeNotifier).removeListener(notifyListeners);
    notifyListeners();
  }

  /// Resolves a path starting with an array index (e.g. `"0"` or `"0.city"`).
  ///
  /// Used internally by [FormGroup] for dot-notation path resolution.
  V getByPath<V>(String path) {
    final dotIndex = path.indexOf('.');
    final indexStr = dotIndex == -1 ? path : path.substring(0, dotIndex);
    final index = int.parse(indexStr);

    if (dotIndex == -1) return _controls[index].formValue as V;

    final rest = path.substring(dotIndex + 1);
    final child = _controls[index];
    if (child is FormGroup) return child.get<V>(rest);

    throw ArgumentError('Cannot navigate array path: "$path"');
  }

  /// Sets a value via a path starting with an array index (e.g. `"0"` or `"0.city"`).
  ///
  /// Used internally by [FormGroup] for dot-notation path resolution.
  void setByPath<V>(String path, V value) {
    final dotIndex = path.indexOf('.');
    final indexStr = dotIndex == -1 ? path : path.substring(0, dotIndex);
    final index = int.parse(indexStr);

    if (dotIndex == -1) {
      (_controls[index] as FormControl<V>).value = value;
      return;
    }

    final rest = path.substring(dotIndex + 1);
    final child = _controls[index];
    if (child is FormGroup) {
      child.set<V>(rest, value);
      return;
    }

    throw ArgumentError('Cannot navigate array path: "$path"');
  }

  /// Resets all child controls to their initial values.
  void reset() {
    for (final c in _controls) {
      if (c is FormControl) c.reset();
      if (c is FormGroup) c.reset();
      if (c is FormArray) c.reset();
    }
  }

  @override
  List<T?> get formValue => _controls.map((c) => c.formValue as T?).toList();

  @override
  bool get isValid => _controls.every((c) => c.isValid);

  @override
  bool get isDirty => _controls.any((c) => c.isDirty);

  @override
  bool get isTouched => _controls.any((c) => c.isTouched);

  @override
  List<String> get errors => _controls.expand((c) => c.errors).toList();

  @override
  void dispose() {
    for (final c in _controls) {
      if (c is ChangeNotifier) {
        (c as ChangeNotifier).removeListener(notifyListeners);
        (c as ChangeNotifier).dispose();
      }
    }
    super.dispose();
  }
}
