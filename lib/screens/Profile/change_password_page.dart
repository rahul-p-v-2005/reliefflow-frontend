import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  bool _isLoading = false;

  Future<void> _changePassword() async {
    // Validation
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar(
        'New password and confirm password do not match',
        isError: true,
      );
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null || token.isEmpty) {
        _showSnackBar(
          'Authentication token not found. Please login again.',
          isError: true,
        );
        return;
      }

      final response = await http.put(
        Uri.parse('$kBaseUrl/public/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar(
          responseBody['message'] ?? 'Password updated successfully',
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnackBar(
          responseBody['message'] ?? 'Failed to update password',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('An error occurred. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.blue[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            PasswordField(
              hintText: "Enter Current Password",
              onChanged: (value) {
                setState(() {
                  currentPassword = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'New Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            PasswordField(
              hintText: "Enter New Password",
              onChanged: (value) {
                setState(() {
                  newPassword = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirm Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            PasswordField(
              hintText: "Confirm Password",
              onChanged: (value) {
                setState(() {
                  confirmPassword = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Update Password',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
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
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          gapPadding: BorderSide.strokeAlignCenter,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
