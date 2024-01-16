import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taskappfirebase/screens/tabs_screen.dart';

import '../screens/register_screen.dart';
import 'package:flutter/material.dart';
import '../screens/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                  obscureText: true,
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
                  final isValid = _formKey.currentState!.validate();
                  _auth
                      .signInWithEmailAndPassword(
                          email: _emailController.text, password: _passwordController.text)
                      .then((value) {
                    GetStorage().write('token', value.user!.uid);
                    GetStorage().write('email', value.user!.email);
                    debugPrint('Get Storage user id: ${GetStorage().read('token')}');
                    Navigator.pushReplacementNamed(context, TabsScreen.id);
                  }).onError((error, stackTrace) {
                    debugPrint('Error string $error');
                    String errorValue = error.toString();
                    String badEmailError = '[firebase_auth/invalid-email';
                    String invalidLoginCred = '[firebase_auth/INVALID_LOGIN_CREDENTIALS';
                    String errorSplit = errorValue.split(']').first;
                    debugPrint('errorValue = $errorValue');
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
                child: const Text('Login'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RegisterScreen.id);
                  },
                  child: const Text('Don\'t have an Account?')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(ForgotPasswordScreen.id);
                  },
                  child: const Text('Forget Password')),
            ],
          ),
        ),
      ),
    );
  }
}
