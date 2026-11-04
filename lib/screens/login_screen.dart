import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/assignment_model.dart';
import '../models/course_model.dart';
import '../data/auth_api.dart';
import '../data/result.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegister = false;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final auth = context.read<AuthApi>();

    final Result<void> result;

    if (_isRegister) {
      result = await auth.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    } else {
      result = await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
    });

    switch (result) {
      case Ok():
        await Future.wait([
          context.read<CourseModel>().load(),
          context.read<AssignmentModel>().load(),
        ]);

        if (!mounted) {
          return;
        }

        context.go('/schedule');

      case Err(:final message):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _toggleMode() {
    if (_busy) {
      return;
    }

    setState(() {
      _isRegister = !_isRegister;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 46,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'EduPlan',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Schedule and education tasks',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isRegister ? 'Create account' : 'Log in',
                              style: theme.textTheme.titleLarge,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              _isRegister
                                  ? 'Create your EduPlan account'
                                  : 'Enter to your account',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),

                            const SizedBox(height: 24),

                            if (_isRegister) ...[
                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) {
                                  if (!_isRegister) {
                                    return null;
                                  }

                                  if (value == null || value.trim().isEmpty) {
                                    return 'Name is required';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),
                            ],

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                final email = value?.trim() ?? '';

                                if (email.isEmpty) {
                                  return 'E-mail is required';
                                }

                                if (!email.contains('@')) {
                                  return 'Enter a valid e-mail';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                _submit();
                              },
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }

                                if (value.length < 6) {
                                  return 'Password must contain at least 6 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            FilledButton.icon(
                              onPressed: _busy ? null : _submit,
                              icon: _busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      _isRegister
                                          ? Icons.person_add
                                          : Icons.login,
                                    ),
                              label: Text(
                                _busy
                                    ? 'Please wait...'
                                    : _isRegister
                                    ? 'Sign up'
                                    : 'Enter',
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextButton(
                              onPressed: _busy ? null : _toggleMode,
                              child: Text(
                                _isRegister
                                    ? 'Already have an account? Log in'
                                    : 'Without account? Sign up',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
