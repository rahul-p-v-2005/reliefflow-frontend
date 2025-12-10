import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/screens/auth/signup_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/main_navigation/main_navigation.dart';
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
        alignment: Alignment.center,
        // width: double.infinity,
        // height: double.infinity,
        // height: double.infinity,
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   alignment: AlignmentGeometry.topCenter,
          //   fit: BoxFit.cover,
          //   image: AssetImage('assets/images/pexels-artempodrez-7233099.jpg'),
          color: const Color.fromARGB(255, 250, 246, 246),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 120),
                    Image.asset(
                      'assets/images/logo3.png',
                      width: 100,
                      height: 100,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Relief',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Flow',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      'Making a diffrenece,Together',
                      style: TextStyle(fontSize: 16.5, color: Colors.grey),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                    PasswordField(
                      hintText: "Password",
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            116,
                            188,
                            247,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _onLoginPressed(email, password);
                        },
                        child: Text(
                          'LOG IN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
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
          MaterialPageRoute<void>(builder: (context) => const MainNavigation()),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(Icons.key),
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


// return Scaffold(
  //   body: Container(
  //     // width: double.infinity,
  //     // height: double.infinity,
  //     // height: double.infinity,
  //     decoration: BoxDecoration(
  //       image: DecorationImage(
  //         alignment: AlignmentGeometry.topCenter,
  //         fit: BoxFit.cover,
  //         image: AssetImage('assets/images/pexels-artempodrez-7233099.jpg'),
  //       ),
  //     ),
  //     child: Center(
  //       child: SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.all(30.0),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               GlassmorphicContainer(
  //                 height: 350,
  //                 width: double.infinity,

  //                 borderRadius: 32,
  //                 blur: 1.5,
  //                 alignment: Alignment.center,
  //                 border: 2,
  //                 linearGradient: LinearGradient(
  //                   colors: [
  //                     Colors.white.withOpacity(0.2),
  //                     Colors.white38.withOpacity(0.2),
  //                   ],
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                 ),
  //                 borderGradient: LinearGradient(
  //                   colors: [
  //                     Colors.white24.withOpacity(0.2),
  //                     Colors.white70.withOpacity(0.2),
  //                   ],
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Column(
  //                     children: [
  //                       Icon(Icons.account_circle, size: 95),
  //                       Text('LOGIN'),
  //                       SizedBox(height: 24),
  //                       TextField(
  //                         decoration: InputDecoration(
  //                           prefixIcon: Icon(Icons.email_outlined),
  //                           // filled: true,
  //                           hintText: "Email",
  //                         ),
  //                         onChanged: (value) {
                            // setState(() {
                            //   email = value;
                            // });
  //                         },
  //                       ),
  //                       SizedBox(height: 8),
  // PasswordField(
  //   hintText: "Password",
  //   onChanged: (value) {
  //     setState(() {
  //       password = value;
  //     });
  //   },
  // ),

  //                       SizedBox(height: 24),
  //                       SizedBox(
  //                         width: double.infinity,
  //                         child: ElevatedButton(
  //                           onPressed: () {
  //                             _onLoginPressed(email, password);
  //                           },
  //                           child: Text('LOGIN'),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Row(
  //                   children: [
  //                     Text("Don't you have an account?,"),
  //                     TextButton(
  //                       onPressed: () {
  //                         Navigator.of(context).push(
  //                           MaterialPageRoute<void>(
  //                             builder: (context) => const SignupScreen(),
  //                           ),
  //                         );
  //                       },
  //                       child: Text("Sign Up"),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   ),
  // );

  // }