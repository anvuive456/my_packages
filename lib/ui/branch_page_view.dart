import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// A [PageView] that listens to a [StatefulNavigationShell] and updates its
/// current page based on the shell's current index.
class BranchPageView extends StatefulWidget {
  /// The [StatefulNavigationShell] to listen to for updates.
  final StatefulNavigationShell shell;

  /// The list of child widgets to display in the [PageView].
  final List<Widget> children;

  /// Creates a [BranchPageView] that listens to the given [shell] and displays
  /// the given [children] in a [PageView].
  const BranchPageView({
    super.key,
    required this.shell,
    required this.children,
  });

  @override
  State<BranchPageView> createState() => _BranchPageViewState();
}

class _BranchPageViewState extends State<BranchPageView> {
  late final PageController _pageController;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.shell.currentIndex);
    _pageController.addListener(_listenToPageController);
  }

  @override
  void didUpdateWidget(covariant BranchPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shell.currentIndex != widget.shell.currentIndex) {
      _isAnimating = true;
      _pageController
          .animateToPage(
            widget.shell.currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) => _isAnimating = false);
    }
  }

  void _listenToPageController() {
    if (_isAnimating) return;
    final page = _pageController.page?.round();
    if (page != null && page != widget.shell.currentIndex) {
      widget.shell.goBranch(page);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(controller: _pageController, children: widget.children);
  }
}
