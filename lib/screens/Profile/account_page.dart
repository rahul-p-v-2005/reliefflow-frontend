import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/screens/Profile/change_password_page.dart';
import 'package:reliefflow_frontend_public_app/screens/Profile/edit_profile.dart';
import 'package:reliefflow_frontend_public_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  File? _selectedImage;
  bool val = true;
  String userName = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch user profile from API
  Future<void> _fetchUserProfile() async {
    const profile = '$kBaseUrl/public/profile';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        kTokenStorageKey,
      ); // ✅ Remove quotes - use the constant directly

      print('Token found: ${token != null}'); // Debug

      if (token == null || token.isEmpty) {
        setState(() {
          userName = 'Not logged in';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(profile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['data']['name'] ?? 'User';
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Error loading name';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = 'Error loading name';
        isLoading = false;
      });
      print('Error fetching user profile: $e');
    }
  }

  // 1. Function to pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // Update the UI if the user successfully picked an image
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  bool val1 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue[50],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      // Text('Profile', style: TextStyle(fontSize: 30)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          _pickImage();
                        },
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  100,
                                ),
                                child: Image.file(
                                  _selectedImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.account_circle_rounded,
                                size: 120,
                              ),
                      ),
                      Text(userName, style: TextStyle(fontSize: 30)),
                      Text(
                        'Public User',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Account Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Profile'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Change Password'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                          );
                        },
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                SizedBox(height: 20),
                Text(
                  'Settings & Preferences',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeThumbColor: Colors.blue,
                        value: val1,
                        onChanged: (bool? value) {
                          setState(() {
                            val1 = value!;
                          });
                        },
                        title: Text('Notification'),
                        secondary: Icon(Icons.notification_add),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.clear();
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (context) => const LoginScreen(),
                        ),
                        (r) => false,
                      );
                    },
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
