// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditInfoPage extends StatefulWidget {
  final String initialInfo; // รับค่า initialInfo มาจากหน้า HomePage
  final User? user;
  final String houseName;
  final Function(String)
      updateInfo; // เพิ่มพารามิเตอร์ updateInfo ที่รับฟังก์ชันเพื่ออัปเดตค่า info

  const EditInfoPage({
    super.key,
    required this.initialInfo,
    required this.user,
    required this.houseName,
    required this.updateInfo,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  final TextEditingController _infoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นของ _infoController จากค่า initialInfo
    _infoController.text = widget.initialInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูล'),
        backgroundColor: const Color(0xFF2F4F4F), // เพิ่มสีพื้นหลังของ AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _infoController,
              decoration: const InputDecoration(
                labelText: 'จำนวนต้น',
                labelStyle: TextStyle(
                  color: Color(0xFF2F4F4F), // เพิ่มสีของ Label
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(
                        0xFF2F4F4F), // เพิ่มสีเส้นกรอบเมื่อ TextField ได้รับความฉลาด
                  ),
                ),
              ),
            ),
            const SizedBox(
                height: 20), // เพิ่มระยะห่างระหว่าง TextField และปุ่ม
            ElevatedButton(
              onPressed: () async {
                // นำค่าที่ผู้ใช้แก้ไขมาใช้งาน
                final updatedInfo = _infoController.text;

                // อัปเดตข้อมูลใน Firestore
                await FirebaseFirestore.instance
                    .collection('sensor_data')
                    .doc(widget.user?.uid)
                    .collection(widget.houseName)
                    .doc('plot')
                    .update({'info': updatedInfo});

                // อัปเดตค่า info ใน State ของ HomePage ผ่านฟังก์ชันที่เราสร้างไว้
                widget.updateInfo(updatedInfo);

                // ส่งค่า updatedInfo กลับไปยังหน้า HomePage
                // ignore: use_build_context_synchronously
                Navigator.pop(context, updatedInfo);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2F4F4F), // เพิ่มสีพื้นหลังของปุ่ม
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
              child: const Text(
                'บันทึก',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _infoController.dispose(); // อย่าลืมจะ dispose _infoController
    super.dispose();
  }
}
