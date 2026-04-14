import 'package:flutter/material.dart';
import 'package:my_packages/state_management/state_management.dart';

// --- Controller ---

final class CounterController extends BaseController<int> {
  CounterController() : super(0);

  @override
  void onInit() {}

  void increment() => state = state + 1;
  void decrement() => state = (state - 1).clamp(0, 999);
  void reset() => state = 0;
}

// --- Page ---

class SharedCounterPage extends StatelessWidget {
  const SharedCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ControllerBuilder.disposable(
      controllerFactory: CounterController.new,
      builder: (context, state, controller) {
        debugPrint(
          '[SharedCounterPage] ControllerBuilder.builder rebuild — state=$state',
        );
        return Scaffold(
          appBar: AppBar(
            title: const Text('Shared Controller'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset',
                onPressed: controller.reset,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _StaticWidget(),
                SizedBox(height: 24),
                _CounterDisplayWidget(),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 24),
                _CounterControlWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Widget A: hiển thị state, có nút tăng ---

class _CounterDisplayWidget extends StatelessWidget {
  const _CounterDisplayWidget();

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of<CounterController, int>(context);
    final count = controller.state;
    debugPrint('[Widget A] build — count=$count');

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Widget A — Display',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '$count',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bình phương: ${count * count}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: controller.increment,
              icon: const Icon(Icons.add),
              label: const Text('Tăng từ Widget A'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget tĩnh: không dùng controller, không phụ thuộc state ---

class _StaticWidget extends StatelessWidget {
  const _StaticWidget();

  @override
  Widget build(BuildContext context) {
    debugPrint('[Static Widget] build');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Tôi là widget tĩnh — không dùng controller',
        textAlign: TextAlign.center,
      ),
    );
  }
}

// --- Widget B: nút giảm, hiển thị trạng thái ---

class _CounterControlWidget extends StatelessWidget {
  const _CounterControlWidget();

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of<CounterController, int>(context);
    final count = controller.state;
    debugPrint('[Widget B] build — count=$count');

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Widget B — Control',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Text(
                  count == 0
                      ? 'Đã về 0'
                      : count % 2 == 0
                      ? 'Số chẵn'
                      : 'Số lẻ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: count > 0 ? controller.decrement : null,
              icon: const Icon(Icons.remove),
              label: const Text('Giảm từ Widget B'),
            ),
          ],
        ),
      ),
    );
  }
}
