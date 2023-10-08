import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: const Color(0xFF2F4F4F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0), // เพิ่มพื้นที่ด้านบนของช่องข้อมูลรหัสผ่าน
            TextFormField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'รหัสปัจจุบัน',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'รหัสใหม่',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'ยืนยันรหัสใหม่',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  String newPassword = _newPasswordController.text;
                  String confirmPassword = _confirmPasswordController.text;

                  if (newPassword == confirmPassword) {
                    try {
                      await user.updatePassword(newPassword);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password changed successfully'),
                        ),
                      );

                      Navigator.of(context).pop();
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error changing password: $error'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New password and confirm password do not match'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save New Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4F4F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
