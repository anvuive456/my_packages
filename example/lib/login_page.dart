import 'package:flutter/material.dart';
import 'package:my_packages/my_packages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final FormGroup _form;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'username': TextFormControl(
        value: '',
        validators: [
          Validators.required(),
          Validators.minLength(3, message: 'At least 3 characters'),
        ],
      ),
      'password': TextFormControl(
        value: '',
        validators: [
          Validators.required(),
          Validators.minLength(6, message: 'At least 6 characters'),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_form.isValid) return;

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login'),
        content: Text('Username: ${_form.get<String>('username')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Form')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          form: _form,
          builder: (context, form) {
            final username = form.text('username');
            final password = form.text('password');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FormField(
                  label: 'Username',
                  controller: username,
                  onBlur: username.markAsTouched,
                  errors: _submitted || username.isTouched ? username.errors : [],
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Password',
                  obscureText: true,
                  controller: password,
                  onBlur: password.markAsTouched,
                  errors: _submitted || password.isTouched ? password.errors : [],
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: form.isValid ? _submit : null,
                  child: const Text('Login'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.onBlur,
    this.errors = const [],
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onBlur;
  final List<String> errors;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) onBlur();
      },
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: errors.isNotEmpty ? errors.first : null,
        ),
      ),
    );
  }
}
