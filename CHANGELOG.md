## 0.1.0

### Added — Form Builder

- `AbstractControl<T>` — generic base interface with `formValue`, `isValid`, `isDirty`, `isTouched`, `errors`, `reset()`.
- `FormControl<T>` — typed value holder with validators and `ChangeNotifier` support.
- `TextFormControl` — extends `TextEditingController`; usable directly as a `TextField` controller with full form integration.
- `FormGroup` — named map of controls with dot-notation path access (`get<T>`, `set<T>`) and typed accessors (`text`, `group`, `array`, `form<T>`).
- `FormArray<T>` — dynamic list of controls with `add`, `removeAt`, `groupAt`.
- `FormBuilder` — widget that binds a `FormGroup` to its subtree via `InheritedNotifier`; rebuilds automatically on any control change.
- `FormScope` — `InheritedNotifier<FormGroup>` for accessing the form from any descendant.
- `Validators` — built-in validator factories: `required`, `minLength`, `maxLength`, `pattern`, `email`, `compose`.

## 0.0.1

- Initial release: `Option<T>`, `Result<T>`, `BaseController`, `ControllerBuilder`, `ControllerScope`.
