import 'package:flutter/widgets.dart';
import 'package:my_packages/form_builder/form_builder.dart';

/// Extension methods for [TextEditingController].
extension TextEditingControllerExt on TextEditingController {
  /// Creates a [TextEditingController] from a [FormControl] value.
  ///
  /// If the [FormControl] value is `null`, an empty [TextEditingController] is returned.
  static TextEditingController fromFormController(
    FormControl<String> formControl,
  ) {
    final text = formControl.formValue;
    if (text == null) {
      return TextEditingController();
    }
    return TextEditingController.fromValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
  }
}
