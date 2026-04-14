import 'package:flutter/widgets.dart';

import 'base_controller.dart';

/// A factory function that creates an instance of a [StateController] subclass.
typedef ControllerFactory<C extends StateController> = C Function();

/// A builder function that receives the current [state] and [controller]
/// and returns a [Widget] to render.
typedef StateBuilder<C extends StateController<S>, S> =
    Widget Function(BuildContext context, S state, C controller);

/// A callback invoked whenever the controller's state changes.
typedef StateListener<S> = void Function(S state);

/// An [InheritedNotifier] that exposes a [StateController] down the widget tree.
///
/// Wrap a subtree with [ControllerScope] to make the controller accessible
/// to any descendant via [ControllerScope.of].
///
/// Example:
/// ```dart
/// ControllerScope<CounterController, int>(
///   controller: myController,
///   child: MyChildWidget(),
/// );
/// ```
class ControllerScope<C extends StateController<S>, S>
    extends InheritedNotifier<C> {
  /// Creates a [ControllerScope] that provides [controller] to its descendants.
  const ControllerScope({
    super.key,
    required C controller,
    required super.child,
  }) : super(notifier: controller);

  /// Looks up the nearest [ControllerScope] of type [C] in the widget tree
  /// and returns its controller.
  ///
  /// Throws if no matching [ControllerScope] is found.
  ///
  /// Example:
  /// ```dart
  /// final controller = ControllerScope.of<CounterController, int>(context);
  /// ```
  static C of<C extends StateController<S>, S>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ControllerScope<C, S>>()!
        .notifier!;
  }
}

/// A [StatefulWidget] that creates, owns, and disposes a [StateController],
/// then rebuilds its subtree whenever the controller's state changes.
///
/// [ControllerBuilder] is the primary way to connect a [BaseController] to the
/// widget tree. It:
/// - Creates the controller via [controllerFactory] on first build.
/// - Exposes the controller to descendants through a [ControllerScope].
/// - Rebuilds the [builder] subtree on every state change.
/// - Calls the optional [listener] on every state change (useful for
///   navigation, snackbars, dialogs, etc.).
///
/// Example:
/// ```dart
/// ControllerBuilder<CounterController, int>(
///   controllerFactory: () => CounterController(),
///   listener: (state) {
///     if (state == 10) ScaffoldMessenger.of(context).showSnackBar(...);
///   },
///   builder: (context, state, controller) {
///     return Text('Count: $state');
///   },
/// );
/// ```
class ControllerBuilder<C extends StateController<S>, S>
    extends StatefulWidget {
  /// A factory used to instantiate the controller exactly once.
  final ControllerFactory<C> controllerFactory;

  /// Called on every state change to rebuild the widget subtree.
  final StateBuilder<C, S> builder;

  /// An optional side-effect callback invoked on every state change.
  ///
  /// Use this for one-time actions (navigation, dialogs, snackbars) that
  /// should not trigger a rebuild.
  final StateListener<S>? listener;

  /// Whether to dispose the controller when the widget is removed from the tree.
  final bool dispose;

  /// Creates a [ControllerBuilder].
  ///
  /// [controllerFactory] and [builder] are required.
  /// [listener] is optional and is only invoked for side effects.
  const ControllerBuilder({
    super.key,
    required this.controllerFactory,
    required this.builder,
    this.listener,
  }) : dispose = false;

  /// Creates a [ControllerBuilder] that disposes
  /// the controller when the widget is removed from the tree.
  ///
  /// If you don't need the controller to be disposed,
  /// use [ControllerBuilder] instead.
  const ControllerBuilder.disposable({
    super.key,
    required this.controllerFactory,
    required this.builder,
    this.listener,
  }) : dispose = true;

  @override
  State<ControllerBuilder<C, S>> createState() =>
      _ControllerBuilderState<C, S>();
}

class _ControllerBuilderState<C extends StateController<S>, S>
    extends State<ControllerBuilder<C, S>> {
  /// The single controller instance for the lifetime of this widget.
  late final C _controller = widget.controllerFactory();

  /// Forwards state-change notifications to [ControllerBuilder.listener].
  void _onStateChanged() => widget.listener?.call(_controller.state);

  @override
  void initState() {
    super.initState();
    if (widget.listener != null) {
      _controller.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    if (widget.dispose) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ControllerScope<C, S>(
      controller: _controller,
      child: _ControllerView<C, S>(builder: widget.builder),
    );
  }
}

/// An internal [StatelessWidget] that reads the controller from the nearest
/// [ControllerScope] and delegates rendering to [builder].
///
/// Separating the view from [_ControllerBuilderState] ensures that only the
/// view subtree is rebuilt on state changes, not the scope itself.
class _ControllerView<C extends StateController<S>, S> extends StatelessWidget {
  /// The builder used to render the current state.
  final StateBuilder<C, S> builder;

  const _ControllerView({required this.builder});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of<C, S>(context);
    return builder(context, controller.state, controller);
  }
}
