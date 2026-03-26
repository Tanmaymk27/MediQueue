import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void _login() {
    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => isLoading = false);
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 60),

            const Text(
              'Welcome Back 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Login to continue',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // 🔹 Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: 'Login',
              isLoading: isLoading,
              onPressed: _login,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don’t have an account?'),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/register'),
                  child: const Text('Register'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}