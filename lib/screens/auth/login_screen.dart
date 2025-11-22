import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/screens/auth/signup_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';

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
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassmorphicContainer(
                    height: 350,
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
                          Text('LOGIN'),
                          SizedBox(height: 24),
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
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
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.key),
                              // filled: true,
                              hintText: "Password",
                            ),
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),

                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _onLoginPressed(email, password);
                              },
                              child: Text('LOGIN'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("Don't you have an account?,"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text("Sign Up"),
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

  Future<void> _onLoginPressed(String email, String password) async {
    const loginRoute = '$kBaseUrl/public/login';

    var body = jsonEncode({
      "email": email,
      "password": password,
    });

    try {
      final response = await post(
        Uri.parse(loginRoute),
        headers: {"Accept": "/", "Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final parsedBody = jsonDecode(response.body) as Map<String, dynamic>;

        print(parsedBody);

        final token = parsedBody['token']; // from backend

        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kTokenStorageKey, token);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
          (r) => false,
        );
      } else {
        print('error');
        final error = jsonDecode(response.body);
        _showError(error['message'] ?? "Login failed");
      }
    } catch (e) {
      _showError("Something went wrong: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
