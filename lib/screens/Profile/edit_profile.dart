import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reliefflow_frontend_public_app/screens/profile/cubit/account_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? name;
  String? email;
  String? address;
  String? phoneNumber;

  @override
  void initState() {
    final userData = (context.read<AccountCubit>().state as AccountLoaded).user;
    name = userData.name;
    email = userData.email;
    address = userData.address;
    phoneNumber = userData.phoneNumber;
    super.initState();
  }

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
    return BlocListener<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountError) {
          // Show error message (401 redirect is handled centrally in MainNavigation)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: state.statusCode == 401 ? Colors.orange : null,
            ),
          );
        } else if (state is AccountLoaded) {
          Navigator.of(context).pop(state.user);
        }
      },
      child: Scaffold(
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
            BlocBuilder<AccountCubit, AccountState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: () {
                    if (name == null ||
                        name!.isEmpty ||
                        email == null ||
                        email!.isEmpty ||
                        address == null ||
                        address!.isEmpty ||
                        phoneNumber == null ||
                        phoneNumber!.isEmpty) {
                      log(
                        'One or more fields are null or empty, field values: name=$name, email=$email, address=$address, phoneNumber=$phoneNumber',
                      );
                      // Show error if any field is null
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill all fields before saving.',
                          ),
                        ),
                      );
                      return;
                    }
                    context.read<AccountCubit>().editAccountDetails(
                      name: name!,
                      email: email!,
                      address: address!,
                      phoneNumber: phoneNumber!,
                    );
                  },
                  child: state is AccountLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                );
              },
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
                    initialValue: name,
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
                    initialValue: email,
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
                    initialValue: address,
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
                    initialValue: phoneNumber,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
              // SizedBox(
              //   width: double.infinity,
              //   height: 55,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Save Logic
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blue,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(15),
              //       ),
              //       elevation: 2,
              //     ),
              //     child: InkWell(
              //       onTap: () {
              //         // Navigator.of(context).push(
              //         //   MaterialPageRoute<void>(
              //         //     builder: (context) => const Account(),
              //         //   ),
              //         // );
              //       },
              //       child: const Text(
              //         "Save Changes",
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 18,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
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
    this.initialValue,
  });

  final void Function(String)? onChanged;

  final String? hintText;

  final TextInputType? keyboardType;

  final String? initialValue;

  @override
  State<EditField> createState() => _EditFieldState();
}

class _EditFieldState extends State<EditField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.initialValue,
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
