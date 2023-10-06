import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_farm/main.dart';

class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์'),
        backgroundColor: const Color(0xFF2F4F4F), // เพิ่มสีพื้นหลังของ AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // รายละเอียดโปรไฟล์
            // ...

            const SizedBox(height: 20),

            // ปุ่มออกจากระบบ
          ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4F4F), // เพิ่มสีพื้นหลังของปุ่ม
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
              ),
              child: const Text('ออกจากระบบ'),
            ),
          ],
        ),
      ),
    );
  }
}
