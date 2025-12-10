import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Using the primary color from your screenshot (Teal/Cyan)
  String name = '';
  String email = '';
  String address = '';
  String phoneNumber = '';

  File? _selectedImage;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Optional 'Save' text button in AppBar
          TextButton(
            onPressed: () {
              // TODO: Add save logic here
            },
            child: Text(
              "Save",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- Profile Image Section ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 4),
                    ),
                  ),

                  _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(100),
                          child: Image.file(
                            _selectedImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.account_circle_rounded, size: 120),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: InkWell(
                        onTap: () {
                          _pickImage();
                        },
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text(
                  'Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                EditField(
                  hintText: "Enter Your Full Name",
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'E-mail',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                EditField(
                  hintText: "Enter Your E-mail",
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                EditField(
                  hintText: "Enter Your Address",
                  onChanged: (value) {
                    setState(() {
                      address = value;
                    });
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Phone Number',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                EditField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  hintText: "+91 ",
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- Main Action Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Save Logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                child: InkWell(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute<void>(
                    //     builder: (context) => const Account(),
                    //   ),
                    // );
                  },
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to keep code clean
}

class EditField extends StatefulWidget {
  const EditField({
    super.key,
    this.onChanged,
    this.hintText,
    this.keyboardType,
  });

  final void Function(String)? onChanged;

  final String? hintText;

  final TextInputType? keyboardType;

  @override
  State<EditField> createState() => _EditFieldState();
}

class _EditFieldState extends State<EditField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      // obscureText: isObscure,
      decoration: InputDecoration(
        // filled: true
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
