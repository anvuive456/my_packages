import 'package:flutter/widgets.dart';

import 'form_group.dart';

/// An [InheritedNotifier] that exposes a [FormGroup] to the widget subtree.
///
/// Automatically triggers rebuilds on all dependent widgets whenever the
/// [FormGroup] (or any of its nested controls) notifies listeners.
///
/// Typically created by [FormBuilder] — you don't need to use this directly.
class FormScope extends InheritedNotifier<FormGroup> {
  /// Creates a [FormScope] wrapping [form] above [child].
  const FormScope({
    super.key,
    required FormGroup form,
    required super.child,
  }) : super(notifier: form);

  /// Returns the nearest [FormGroup] from the widget tree.
  ///
  /// Throws if no [FormScope] is found above in the tree.
  static FormGroup of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FormScope>();
    assert(scope != null, 'No FormScope found in widget tree. Wrap your widget with FormBuilder.');
    return scope!.notifier!;
  }
}
