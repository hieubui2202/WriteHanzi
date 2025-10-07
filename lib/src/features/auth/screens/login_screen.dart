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
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Hanzi Writing Trainer', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      if (_isLogin) {
                        await authService.signInWithEmailAndPassword(email, password);
                      } else {
                        await authService.createUserWithEmailAndPassword(email, password);
                      }
                    }
                  },
                  child: Text(_isLogin ? 'Login' : 'Create Account'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin ? 'Create an account' : 'Have an account? Login'),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login), // Replace with a proper Google icon if you have one
                  label: const Text('Sign in with Google'),
                  onPressed: () async {
                    await authService.signInWithGoogle();
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                     await authService.signInAnonymously();
                  },
                  child: const Text('Continue as Guest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
