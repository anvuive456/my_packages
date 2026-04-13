import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      'image': FormControl<File>(),
      'username': TextFormControl(
        value: '',
        validators: [
          Validators.required(),
          Validators.minLength(3, message: 'At least 3 characters'),
        ],
      ),
      'email': TextFormControl(
        value: '',
        validators: [Validators.required(), Validators.email()],
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

  void _submit() async {
    setState(() => _submitted = true);
    if (!_form.isValid) return;

    await showDialog<void>(
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

    _form.reset();
    setState(() => _submitted = false);
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
            final email = form.text('email');
            final password = form.text('password');
            final file = form.form<File>('image');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FileField(file: file.formValue, onPick: (v) => file.value = v),
                _FormField(
                  label: 'Username',
                  controller: username,
                  onBlur: username.markAsTouched,
                  errors: _submitted || username.isTouched
                      ? username.errors
                      : [],
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Email',
                  controller: email,
                  onBlur: email.markAsTouched,
                  errors: _submitted || email.isTouched ? email.errors : [],
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Password',
                  obscureText: true,
                  controller: password,
                  onBlur: password.markAsTouched,
                  errors: _submitted || password.isTouched
                      ? password.errors
                      : [],
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

class _FileField extends StatelessWidget {
  final File? file;
  final ValueChanged<File?> onPick;
  const _FileField({super.key, this.file, required this.onPick});

  void _pickFile() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      onPick(File.fromUri(Uri.parse(result.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      return ElevatedButton(onPressed: _pickFile, child: const Text('Upload'));
    }
    return SizedBox(height: 300, child: Image.file(file!, fit: BoxFit.cover));
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
          errorText: errors.isNotEmpty ? errors.join(', ') : null,
        ),
      ),
    );
  }
}
