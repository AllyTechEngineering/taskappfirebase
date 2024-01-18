import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskappfirebase/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const id = 'register_screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance; //video 21 at 1:10

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Insert email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Insert password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  } else if (value.length < 6) {
                    return 'Password should be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // final isValid = _formKey.currentState!.validate();
                _auth
                    .createUserWithEmailAndPassword(
                        email: _emailController.text, password: _passwordController.text)
                    .then((value) {
                  Navigator.pushReplacementNamed(context, LoginScreen.id);
                }).onError((error, stackTrace) {
                  debugPrint('Error string $error');
                  String errorValue = error.toString();
                  String badEmailError = '[firebase_auth/invalid-email';
                  String invalidLoginCred = '[firebase_auth/INVALID_LOGIN_CREDENTIALS';
                  String errorSplit = errorValue.split(']').first;
                  debugPrint('Test of errorSplit: $errorSplit');
                  if (errorSplit == badEmailError) {
                    var snackBar = SnackBar(
                      duration: Duration(milliseconds: 2000),
                      backgroundColor: Colors.red,
                      content: Text(
                        'Error: please check your email or password.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else if (errorSplit == invalidLoginCred) {
                    var snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(milliseconds: 2000),
                      content: Text(
                        'Error: invalid log in credentials.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    var snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        'Error: $error',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                });
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
