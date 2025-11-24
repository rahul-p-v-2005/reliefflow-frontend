import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/screens/auth/login_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/home/home_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/main_navigation/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phoneNo = '';
  String address = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // width: double.infinity,
        // height: double.infinity,
        // height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: AlignmentGeometry.topCenter,
            fit: BoxFit.cover,
            image: AssetImage('assets/images/pexels-artempodrez-7233099.jpg'),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassmorphicContainer(
                    height: 630,
                    width: double.infinity,

                    borderRadius: 32,
                    blur: 1.5,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white38.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.white24.withOpacity(0.2),
                        Colors.white70.withOpacity(0.2),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.account_circle, size: 95),
                          Text('Sign Up'),
                          SizedBox(height: 24),
                          TextField(
                            decoration: InputDecoration(
                              // filled: true,
                              hintText: "Name",
                            ),
                            onChanged: (value) {
                              setState(() {
                                name = value;
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              // prefixIcon: Icon(Icons.email_outlined),
                              // filled: true,
                              hintText: "Email",
                            ),
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          PasswordField(
                            hintText: "Password",
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          PasswordField(
                            hintText: "Confirm Password",
                            onChanged: (value) {
                              setState(() {
                                confirmPassword = value;
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              // filled: true,
                              hintText: "Phone Number",
                            ),
                            onChanged: (value) {
                              setState(() {
                                phoneNo = value;
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              // filled: true,
                              hintText: "Address",
                            ),
                            onChanged: (value) {
                              setState(() {
                                address = value;
                              });
                            },
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (password != confirmPassword) {
                                  //
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Passwords do not match'),
                                    ),
                                  );
                                }
                                _onSignUpPressed(
                                  name,
                                  email,
                                  password,
                                  confirmPassword,
                                  phoneNo,
                                  address,
                                );
                              },
                              child: Text('SIGN UP'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text("Login"),
                        ),
                      ],
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

  Future<void> _onSignUpPressed(
    String name,
    String email,
    String password,
    String confirmPassword,
    String phoneNo,
    String address,
  ) async {
    const loginRoute = '$kBaseUrl/public/signup';

    var body = jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      "phoneNumber": phoneNo,
      "address": address,
    });

    try {
      final response = await http.post(
        Uri.parse(loginRoute),
        headers: {"Accept": "/", "Content-Type": "application/json"},
        body: body,
      );

      log(response.body);

      if (response.statusCode == 201) {
        log('ssss');
        final parsedBody = jsonDecode(response.body) as Map<String, dynamic>;

        log(parsedBody.toString());

        final token = parsedBody['token']; // from backend

        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kTokenStorageKey, token);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (context) => const MainNavigation()),
          (r) => false,
        );
      } else {
        log(response.body);
        final error = jsonDecode(response.body);
        _showError(error['message'] ?? "Sign up failed");
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
      _showError("Something went wrong: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({super.key, this.onChanged, this.hintText});

  final void Function(String)? onChanged;

  final String? hintText;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isObscure,

      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isObscure = !isObscure;
            });
          },
          icon: Icon(isObscure ? Icons.visibility_off : Icons.remove_red_eye),
        ),
        // filled: true,
        hintText: widget.hintText,
      ),
      onChanged: widget.onChanged,
    );
  }
}
