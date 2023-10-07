import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farm/camera_page.dart';
import 'package:smart_farm/edit_data_page.dart';
import 'package:smart_farm/home_page.dart';
import 'package:smart_farm/note/note_page.dart';
import 'package:smart_farm/profile/profile_page.dart';

class HousePage extends StatefulWidget {
  final User? user;
  final String houseName;
  final int houseNumber;

  const HousePage({
    Key? key,
    required this.user,
    required this.houseName,
    required this.houseNumber,
  }) : super(key: key);

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  int _currentIndex = 0;
  String vegetableName = "";
  String plantVariety = "";
  String info = "";
  String plantingDate = "";

  double humidity = 0.0;
  double soilMoisture = 0.0;
  double temperature = 0.0;
  int pumpState = 0;
  int lampState = 0;

  TextEditingController vegetableNameController = TextEditingController();
  TextEditingController plantVarietyController = TextEditingController();
  TextEditingController infoController = TextEditingController();
  TextEditingController plantingDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sensor_data')
              .doc(widget.user?.uid)
              .collection(widget.houseName)
              .doc('plot')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final data = snapshot.data?.data() as Map<String, dynamic>?;
            if (data != null) {
              vegetableName = data['vegetableName'] ?? '';
              plantVariety = data['plantVariety'] ?? '';
              info = data['info'] ?? '';
              plantingDate = data['plantingDate'] ?? '';
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 411.4,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F4F4F),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 120,
                            ),
                            Text(
                              'โรงเรือน ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(
                              width: 70,
                            )
                          ],
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          height: 180,
                          width: 415,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F4F4F),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 80,
                          width: 411.4,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F4F4F),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: const Row(
                              children: [
                                BackButton(
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            height: 160,
                            width: 370,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 68, 115, 115),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  height: 30,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditDataPage(
                                            user: widget.user,
                                            houseName: widget.houseName,
                                            vegetableName:
                                                vegetableName, // ตรวจสอบว่าคุณกำหนดค่า vegetableName ให้ถูกต้อง
                                            plantVariety:
                                                plantVariety, // ตรวจสอบว่าคุณกำหนดค่า plantVariety ให้ถูกต้อง
                                            info:
                                                info, // ตรวจสอบว่าคุณกำหนดค่า info ให้ถูกต้อง
                                            plantingDate:
                                                plantingDate, // ตรวจสอบว่าคุณกำหนดค่า plantingDate ให้ถูกต้อง
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          ' ชื่อผัก                     :',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              data?['vegetableName'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditDataPage(
                                            user: widget.user,
                                            houseName: widget.houseName,
                                            vegetableName:
                                                vegetableName, // ตรวจสอบว่าคุณกำหนดค่า vegetableName ให้ถูกต้อง
                                            plantVariety:
                                                plantVariety, // ตรวจสอบว่าคุณกำหนดค่า plantVariety ให้ถูกต้อง
                                            info:
                                                info, // ตรวจสอบว่าคุณกำหนดค่า info ให้ถูกต้อง
                                            plantingDate:
                                                plantingDate, // ตรวจสอบว่าคุณกำหนดค่า plantingDate ให้ถูกต้อง
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          ' สายพันธ์ุ                 :',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              data?['plantVariety'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditDataPage(
                                            user: widget.user,
                                            houseName: widget.houseName,
                                            vegetableName:
                                                vegetableName, // ตรวจสอบว่าคุณกำหนดค่า vegetableName ให้ถูกต้อง
                                            plantVariety:
                                                plantVariety, // ตรวจสอบว่าคุณกำหนดค่า plantVariety ให้ถูกต้อง
                                            info:
                                                info, // ตรวจสอบว่าคุณกำหนดค่า info ให้ถูกต้อง
                                            plantingDate:
                                                plantingDate, // ตรวจสอบว่าคุณกำหนดค่า plantingDate ให้ถูกต้อง
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          ' จำนวนต้นทั้งหมด  :',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              data?['info'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditDataPage(
                                            user: widget.user,
                                            houseName: widget.houseName,
                                            vegetableName:
                                                vegetableName, // ตรวจสอบว่าคุณกำหนดค่า vegetableName ให้ถูกต้อง
                                            plantVariety:
                                                plantVariety, // ตรวจสอบว่าคุณกำหนดค่า plantVariety ให้ถูกต้อง
                                            info:
                                                info, // ตรวจสอบว่าคุณกำหนดค่า info ให้ถูกต้อง
                                            plantingDate:
                                                plantingDate, // ตรวจสอบว่าคุณกำหนดค่า plantingDate ให้ถูกต้อง
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          ' วันที่เพาะกล้า         :',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              data?['plantingDate'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('user_notes')
                          .doc(widget.user?.uid)
                          .collection('notes')
                          .orderBy('day',
                              descending:
                                  true) // เรียงลำดับตามฟิลด์ day ในลำดับตกลง
                          .limit(1) // จำกัดให้ดึงเอกสารเพียง 1 รายการ
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final documents = snapshot.data?.docs;

                        if (documents != null && documents.isNotEmpty) {
                          final latestDocument =
                              documents.first.data() as Map<String, dynamic>;

                         final goodVegetable =
                              latestDocument['goodVegetable'] ?? '';
                          final badVegetable =
                              latestDocument['badVegetable'] ?? '';

                          return Row(
                            children: [
                              const SizedBox(
                                width: 45,
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 133, 176, 130),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          '     ต้นปกติ      ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          goodVegetable,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 186, 127, 114),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            const Text(
                                              '  ต้นที่พบโรค   ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Text(
                                              badVegetable,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // หากไม่มีเอกสารให้แสดงข้อความว่าไม่มีข้อมูล
                          return const Center(child: Text('ไม่มีข้อมูล'));
                        }
                      },
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('sensor_data')
                          .doc(widget.user?.uid)
                          .collection(widget.houseName)
                          .doc('plot')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        final data =
                            snapshot.data?.data() as Map<String, dynamic>?;

                        if (data != null) {
                          humidity =
                              (data['humidity'] as num?)?.toDouble() ?? 0.0;
                          soilMoisture =
                              (data['soilMoisture'] as num?)?.toDouble() ?? 0.0;
                          temperature =
                              (data['temperature'] as num?)?.toDouble() ?? 0.0;
                          pumpState =
                              (data['pump_state'] as num?)?.toInt() ?? 0;
                          lampState =
                              (data['lamp_state'] as num?)?.toInt() ?? 0;
                        }

                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 180,
                                        width: 120,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2F4F4F),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 60,
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(60),
                                                image: const DecorationImage(
                                                  image: AssetImage(
                                                      'images/ชื้นอากาศ.jpg'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              'ความชื้น',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Text(
                                              'ในอากาศ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              ' ${humidity.toStringAsFixed(2)} %',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 180,
                                        width: 120,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2F4F4F),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 60,
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                image: const DecorationImage(
                                                  image: AssetImage(
                                                      'images/ชื้นดิน.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              'ความชื้น',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Text(
                                              'ในดิน',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              ' ${soilMoisture.toStringAsFixed(2)} %',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 180,
                                        width: 120,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2F4F4F),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 60,
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                image: const DecorationImage(
                                                  image: AssetImage(
                                                      'images/อุณหภูมิ.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            const Text(
                                              'อุณหภูมิ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              ' ${temperature.toStringAsFixed(2)} °C',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 80,
                                        width: 200,
                                        padding: const EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 113, 149, 149),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.lightbulb,
                                                size: 40),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            const Text(
                                              'หลอดไฟ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              child: Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 13,
                                                  ),
                                                  Switch(
                                                    value: lampState == 1,
                                                    onChanged: (value) {
                                                      int newLampState =
                                                          value ? 1 : 0;
                                                      setState(() {
                                                        lampState =
                                                            newLampState;
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'sensor_data')
                                                          .doc(widget.user?.uid)
                                                          .collection(
                                                              widget.houseName)
                                                          .doc('plot')
                                                          .update({
                                                        'lamp_state':
                                                            newLampState,
                                                      }).then((_) {
                                                        print(
                                                            'อัปเดตสถานะหลอดไฟสำเร็จ');
                                                      }).catchError((error) {
                                                        print(
                                                            'เกิดข้อผิดพลาดในการอัปเดตหลอดไฟ: $error');
                                                      });
                                                    },
                                                    activeColor: Colors.white,
                                                    activeTrackColor:
                                                        Colors.white,
                                                    inactiveThumbColor:
                                                        Colors.grey[300],
                                                    inactiveTrackColor:
                                                        Colors.grey[300],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 80,
                                        width: 200,
                                        padding: const EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 113, 149, 149),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.water_damage,
                                                size: 40),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text(
                                              'ปั๊มน้ำ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              child: Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 13,
                                                  ),
                                                  Switch(
                                                    value: pumpState == 1,
                                                    onChanged: (value) {
                                                      int newPumpState =
                                                          value ? 1 : 0;
                                                      setState(() {
                                                        pumpState =
                                                            newPumpState;
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'sensor_data')
                                                          .doc(widget.user?.uid)
                                                          .collection(
                                                              widget.houseName)
                                                          .doc('plot')
                                                          .update({
                                                        'pump_state':
                                                            newPumpState,
                                                      }).then((_) {
                                                        print(
                                                            'อัปเดตสถานะปั๊มน้ำสำเร็จ');
                                                      }).catchError((error) {
                                                        print(
                                                            'เกิดข้อผิดพลาดในการอัปเดตปั๊มน้ำ: $error');
                                                      });
                                                    },
                                                    activeColor: Colors.white,
                                                    activeTrackColor:
                                                        Colors.white,
                                                    inactiveThumbColor:
                                                        Colors.grey[300],
                                                    inactiveTrackColor:
                                                        Colors.grey[300],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // เพิ่มส่วน UI ที่คุณต้องการแสดงต่อไปได้ที่นี่
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            switch (index) {
              case 0:
                // เส้นทางสำหรับไอคอน "หน้าหลัก"
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      widget.user, // ส่ง user ไปยัง HomePage
                    ),
                  ),
                );
                break;
              case 1:
                // เส้นทางสำหรับไอคอน "Note"
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewNotesPage(user: widget.user),
                  ),
                );
                break;
              case 2:
                // เส้นทางสำหรับไอคอน "Camera"
                Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  CameraPage(
                           user: widget.user
                           
                          ),
                        ),
                      );
                break;
              case 3:
                // เส้นทางสำหรับไอคอน "ค้นหา"
                break;
              case 4:
                // เส้นทางสำหรับไอคอน "โปรไฟล์"
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Color(0xFF2F4F4F),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note),
              label: 'Note',
              backgroundColor: Color(0xFF2F4F4F),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'Camera',
              backgroundColor: Color(0xFF2F4F4F),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
              backgroundColor: Color(0xFF2F4F4F),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Color(0xFF2F4F4F),
            ),
          ],
        ),
      ),
    );
  }
}
