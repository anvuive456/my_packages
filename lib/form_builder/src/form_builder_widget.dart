import 'package:flutter/widgets.dart';

import 'form_group.dart';
import 'form_scope.dart';

/// A widget that binds a [FormGroup] to its subtree via [FormScope].
///
/// Rebuilds the [builder] whenever any control in [form] changes.
///
/// Create the [FormGroup] outside this widget (e.g. in your State or
/// state management layer) so it persists across rebuilds.
///
/// ```dart
/// final form = FormGroup({
///   'username': FormControl<String>(value: ''),
/// });
///
/// FormBuilder(
///   form: form,
///   builder: (context, form) => TextField(
///     initialValue: form.get<String>('username'),
///     onChanged: (v) => form.set('username', v),
///   ),
/// )
/// ```
class FormBuilder extends StatelessWidget {
  /// Creates a [FormBuilder] with the given [form] and [builder].
  const FormBuilder({
    super.key,
    required this.form,
    required this.builder,
  });

  /// The form group to bind to the subtree.
  final FormGroup form;

  /// Called to build the widget tree, receiving the current [FormGroup].
  final Widget Function(BuildContext context, FormGroup form) builder;

  @override
  Widget build(BuildContext context) {
    return FormScope(
      form: form,
      child: Builder(
        builder: (ctx) => builder(ctx, FormScope.of(ctx)),
      ),
    );
  }
}
