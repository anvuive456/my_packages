import 'package:flutter/material.dart';

import 'login_page.dart';
import 'shared_counter_page.dart';
import 'todo_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormBuilder Examples',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FormBuilder Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleTile(
            icon: Icons.login,
            title: 'Login Form',
            subtitle: 'FormControl + Validators',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleTile(
            icon: Icons.checklist,
            title: 'Todo List',
            subtitle: 'FormArray + nested FormGroup',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const TodoPage()),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleTile(
            icon: Icons.share,
            title: 'Shared Controller',
            subtitle: '2 widget dùng chung 1 controller',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (_) => const SharedCounterPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
