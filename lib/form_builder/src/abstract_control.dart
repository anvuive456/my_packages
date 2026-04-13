/// Base interface for all form controls ([FormControl], [FormGroup], [FormArray]).
abstract class AbstractControl<T> {
  /// The typed form value of this control.
  T get formValue;

  /// Whether all validators pass for this control (and its descendants).
  bool get isValid;

  /// Whether the value has been changed at least once since initialization or last reset.
  bool get isDirty;

  /// Whether this control has been marked as touched (e.g. on blur).
  bool get isTouched;

  /// The list of validation error messages for this control.
  List<String> get errors;

  /// Resets the control to its initial state.
  void reset();
}
