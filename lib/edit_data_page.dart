import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDataPage extends StatefulWidget {
  final User? user;
  final String houseName;
  final String vegetableName;
  final String plantVariety;
  final String info;
  final String plantingDate;

  const EditDataPage({
    Key? key,
    required this.user,
    required this.houseName,
    required this.vegetableName,
    required this.plantVariety,
    required this.info,
    required this.plantingDate,
  }) : super(key: key);

  @override
  _EditDataPageState createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  final TextEditingController vegetableNameController = TextEditingController();
  final TextEditingController plantVarietyController = TextEditingController();
  final TextEditingController infoController = TextEditingController();
  final TextEditingController plantingDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // กำหนดค่าใน TextEditingController จากข้อมูลที่รับมา
    vegetableNameController.text = widget.vegetableName;
    plantVarietyController.text = widget.plantVariety;
    infoController.text = widget.info;
    plantingDateController.text = widget.plantingDate;
  }

  Future<void> updateDataInFirestore() async {
    // สร้าง Map ที่มีข้อมูลที่คุณต้องการบันทึก
    Map<String, dynamic> dataToSave = {
      'vegetableName': vegetableNameController.text,
      'plantVariety': plantVarietyController.text,
      'info': infoController.text,
      'plantingDate': plantingDateController.text,
    };

    try {
      // ใช้ update() เพื่ออัปเดตข้อมูลเพิ่มเข้าไปในเอกสารที่มีอยู่และเพิ่มข้อมูลใหม่
      await FirebaseFirestore.instance
          .collection('sensor_data') // เปลี่ยนเป็นชื่อคอลเล็กชันของคุณ
          .doc(widget.user?.uid)
          .collection(widget.houseName)
          .doc('plot') // เปลี่ยนเป็น ID เอกสารที่คุณต้องการบันทึก
          .update(dataToSave);

      // อัปเดตข้อมูลเรียบร้อย
      print('อัปเดตข้อมูลเรียบร้อยแล้ว');
    } catch (error) {
      // มีข้อผิดพลาดเกิดขึ้นในการบันทึกข้อมูล
      print('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูล'),
        backgroundColor: const Color(0xFF2F4F4F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: vegetableNameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อผัก',
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: plantVarietyController,
              decoration: const InputDecoration(
                labelText: 'สายพันธุ์',
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: infoController,
              decoration: const InputDecoration(
                labelText: 'จำนวนต้นทั้งหมด',
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (selectedDate != null) {
                  setState(() {
                    plantingDateController.text =
                        "${selectedDate.toLocal()}".split(' ')[0];
                  });
                }
              },
              child: TextFormField(
                controller: plantingDateController,
                enabled: false, // ปิดการใช้งาน TextFormField ตรงนี้
                decoration: const InputDecoration(
                  labelText: 'วันที่เพาะกล้า',
                  labelStyle: TextStyle(fontSize: 18),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                  ), // ไอคอนสำหรับแสดงตัวเลือกวันที่
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // ตรวจสอบว่าข้อมูลถูกป้อนครบถ้วนหรือไม่
                if (vegetableNameController.text.isNotEmpty &&
                    plantVarietyController.text.isNotEmpty &&
                    infoController.text.isNotEmpty &&
                    plantingDateController.text.isNotEmpty) {
                  // ถ้าข้อมูลถูกป้อนครบถ้วน ให้ทำการบันทึกข้อมูล
                  updateDataInFirestore().then((_) {
                    // หลังจากบันทึกข้อมูลเรียบร้อยแล้ว กลับไปหน้า HousePage
                    Navigator.pop(context);
                  });
                } else {
                  // ถ้าข้อมูลยังไม่ถูกป้อนครบถ้วน ให้แสดงข้อความแจ้งเตือน
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('ข้อมูลไม่ครบถ้วน'),
                        content: Text('กรุณากรอกข้อมูลให้ครบถ้วนก่อนบันทึก'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('ตกลง'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF2F4F4F),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'บันทึกข้อมูล',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
