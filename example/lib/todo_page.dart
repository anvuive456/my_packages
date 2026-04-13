import 'package:flutter/material.dart';
import 'package:my_packages/my_packages.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late final FormGroup _form;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'todos': FormArray<FormGroup>([
        _buildTodoControl('Buy groceries'),
        _buildTodoControl('Walk the dog'),
      ]),
      'newTodo': TextFormControl(value: ''),
    });
  }

  FormGroup _buildTodoControl(String title) {
    return FormGroup({
      'title': TextFormControl(value: title),
      'done': FormControl<bool>(value: false),
    });
  }

  void _addTodo() {
    final title = _form.get<String>('newTodo').trim();
    if (title.isEmpty) return;

    _form.array('todos').add(_buildTodoControl(title));
    _form.set('newTodo', '');
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: FormBuilder(
        form: _form,
        builder: (context, form) {
          final todos = form.array('todos');
          final doneCount = List.generate(todos.length, todos.groupAt)
              .where((g) => g.get<bool>('done') == true)
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: form.text('newTodo'),
                        decoration: const InputDecoration(
                          hintText: 'New todo...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _addTodo(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: _addTodo, child: const Text('Add')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$doneCount / ${todos.length} completed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Divider(),
              Expanded(
                child: todos.length == 0
                    ? const Center(child: Text('No todos yet.'))
                    : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, i) {
                          final todo = todos.groupAt(i);
                          return _TodoItem(
                            todo: todo,
                            onRemove: () => todos.removeAt(i),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TodoItem extends StatelessWidget {
  const _TodoItem({required this.todo, required this.onRemove});

  final FormGroup todo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      form: todo,
      builder: (context, form) {
        final done = form.get<bool>('done');
        return ListTile(
          leading: Checkbox(
            value: done,
            onChanged: (v) => form.set('done', v == true),
          ),
          title: Text(
            form.get<String>('title'),
            style: done
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        );
      },
    );
  }
}
