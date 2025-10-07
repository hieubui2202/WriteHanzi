import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController(); // Add this
  bool _isLogin = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runAuthFlow(BuildContext context, Future<void> Function() action)
      async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      await action();
    } on AuthFailure catch (e) {
      _showMessage(context, e.message);
    } catch (e) {
      _showMessage(context, 'Có lỗi xảy ra: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: AbsorbPointer(
                absorbing: _isSubmitting,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Hanzi Writing Trainer',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 32),
                      if (!_isLogin)
                        TextFormField(
                          controller: _displayNameController,
                          decoration:
                              const InputDecoration(labelText: 'Display Name'),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Enter a display name'
                              : null,
                        ),
                      if (!_isLogin) const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            (value == null || !value.contains('@'))
                                ? 'Enter a valid email'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) =>
                            (value == null || value.length < 6)
                                ? 'Password must be at least 6 characters'
                                : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();
                                    await _runAuthFlow(context, () async {
                                      if (_isLogin) {
                                        await authService
                                            .signInWithEmailAndPassword(
                                          email,
                                          password,
                                        );
                                      } else {
                                        final displayName =
                                            _displayNameController.text.trim();
                                        await authService
                                            .createUserWithEmailAndPassword(
                                          email,
                                          password,
                                          displayName,
                                        );
                                      }
                                    });
                                  }
                                },
                          child: Text(
                            _isLogin ? 'Login' : 'Create Account',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                        child: Text(_isLogin
                            ? 'Create an account'
                            : 'Have an account? Login'),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text('Sign in with Google'),
                          onPressed: _isSubmitting
                              ? null
                              : () => _runAuthFlow(context, () async {
                                    await authService.signInWithGoogle();
                                  }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _runAuthFlow(context, () async {
                                  await authService.signInAnonymously();
                                }),
                        child: const Text('Continue as Guest'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isSubmitting)
              const Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
