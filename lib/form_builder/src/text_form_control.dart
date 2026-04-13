import 'package:flutter/widgets.dart';

import 'abstract_control.dart';
import 'form_control.dart';

/// A [TextEditingController] that also acts as a form control.
///
/// Can be passed directly to [TextField] or [TextFormField] as [controller],
/// while also working inside a [FormGroup] as a first-class control.
///
/// Notifies listeners (and thus [FormGroup]) whenever the text changes,
/// so [FormBuilder] rebuilds automatically.
///
/// ```dart
/// final form = FormGroup({
///   'email': TextFormControl(
///     value: '',
///     validators: [Validators.required()],
///   ),
/// });
///
/// // In build:
/// TextField(
///   controller: form.text('email'),
/// )
/// ```
class TextFormControl extends TextEditingController
    implements AbstractControl<String> {
  /// Creates a [TextFormControl] with an optional initial [value] and [validators].
  TextFormControl({String? value, this.validators = const []})
    : super(text: value ?? '');

  /// The list of validators applied to this control's text value.
  final List<Validator<String>> validators;

  bool _isDirty = false;
  bool _isTouched = false;

  @override
  String get formValue => text;

  @override
  set value(TextEditingValue newValue) {
    if (super.value.text != newValue.text) {
      // Set dirty BEFORE super call so listeners see the correct state.
      _isDirty = true;
    }
    super.value = newValue;
  }

  @override
  bool get isDirty => _isDirty;

  @override
  bool get isTouched => _isTouched;

  @override
  List<String> get errors => validators
      .map((v) => v(text.isEmpty ? null : text))
      .whereType<String>()
      .toList();

  @override
  bool get isValid => errors.isEmpty;

  /// Marks this control as touched (e.g. call on focus lost).
  void markAsTouched() {
    if (_isTouched) return;
    _isTouched = true;
    notifyListeners();
  }

  @override
  /// Resets the text to [value] and clears dirty and touched state.
  void reset() {
    // Set flags before super.value to ensure correct state during notification.
    _isDirty = false;
    _isTouched = false;
    super.value = TextEditingValue();
  }
}
