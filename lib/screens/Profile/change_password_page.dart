import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: Colors.blue[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              PasswordField(
                hintText: "Enter Current Password",
                onChanged: (value) {
                  setState(() {
                    currentPassword = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                'New Password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              PasswordField(
                hintText: "Enter New Password",
                onChanged: (value) {
                  setState(() {
                    newPassword = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                'Confirm Password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              PasswordField(
                hintText: "Confirm Password",
                onChanged: (value) {
                  setState(() {
                    confirmPassword = value;
                  });
                },
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(15),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {},
                  child: Text(
                    'Update Password',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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
