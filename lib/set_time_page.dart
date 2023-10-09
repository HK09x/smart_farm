import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetTimePage extends StatefulWidget {
  final User? user;
  const SetTimePage({Key? key, this.user}) : super(key: key);

  @override
  State<SetTimePage> createState() => _SetTimePageState();
}

class _SetTimePageState extends State<SetTimePage> {
  Timer? timer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    // ใน initState สร้าง Timer เพื่อตรวจสอบเวลาทุก ๆ 1 นาที
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      final now = TimeOfDay.now();

      // ตรวจสอบเวลาของทุกโรงเรือนและส่งค่าไป Firebase Cloud Firestore โดยอัตโนมัติ
      for (final building in buildings) {
        if (now == building.startTime || now == building.endTime) {
          // ถ้าเวลาเริ่มหรือเวลาสิ้นสุดตรงกับเวลาที่ตั้งไว้
          if (building.selectedAction != BuildingAction.none) {
            // ตรวจสอบว่ามีการทำงานที่เลือกหรือไม่
            _performSelectedAction(building);
          }
        } else if (now == building.endTime) {
          // ถ้าเวลาปัจจุบันตรงกับเวลาสิ้นสุด
          if (building.selectedAction != BuildingAction.none) {
            // ส่งค่าปิดไปยัง Firebase Firestore
            _turnOffBuilding(building);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel(); // ยกเลิก Timer เมื่อหน้า SetTimePage ถูก dispose
  }

  List<Building> buildings = [
    Building(
        name: 'โรงเรือน 1',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now(),
        selectedAction: BuildingAction.none), // เพิ่ม selectedAction ให้กับแต่ล่ะโรงเรือน
    Building(
        name: 'โรงเรือน 2',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now(),
        selectedAction: BuildingAction.none),
    Building(
        name: 'โรงเรือน 3',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now(),
        selectedAction: BuildingAction.none),
    Building(
        name: 'โรงเรือน 4',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now(),
        selectedAction: BuildingAction.none),
    Building(
        name: 'โรงเรือน 5',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now(),
        selectedAction: BuildingAction.none),
  ];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _showActionDialog(Building building) async {
    final selectedAction = await showDialog<BuildingAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เลือกการทำงานสำหรับ ${building.name}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text('เปิดปิมน้ำอย่างเดียว'),
                  onTap: () {
                    Navigator.of(context).pop(BuildingAction.togglePump);
                  },
                ),
                ListTile(
                  title: Text('เปิดหลอดไฟอย่างเดียว'),
                  onTap: () {
                    Navigator.of(context).pop(BuildingAction.toggleLight);
                  },
                ),
                ListTile(
                  title: Text('เปิดทั้งปิมน้ำและหลอดไฟ'),
                  onTap: () {
                    Navigator.of(context)
                        .pop(BuildingAction.togglePumpAndLight);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(BuildingAction.none);
              },
            ),
          ],
        );
      },
    );

    // ตั้งค่า selectedAction สำหรับโรงเรือน
    setState(() {
      building.selectedAction = selectedAction ?? BuildingAction.none;
    });
  }

  void _performSelectedAction(Building building) {
    final now = TimeOfDay.now();

    // ตรวจสอบ selectedAction และดำเนินการตามที่เลือก
    switch (building.selectedAction) {
      case BuildingAction.togglePump:
        _togglePump(building);
        break;
      case BuildingAction.toggleLight:
        _toggleLight(building);
        break;
      case BuildingAction.togglePumpAndLight:
        _togglePumpAndLight(building);
        break;
      default:
        break;
    }

    // เมื่อถึงเวลาสิ้นสุด
    if (now == building.endTime) {
      // ตรวจสอบ selectedAction และส่งค่าปิดไปยัง Firebase Firestore
      switch (building.selectedAction) {
        case BuildingAction.togglePump:
          _turnOffPump(building);
          break;
        case BuildingAction.toggleLight:
          _turnOffLight(building);
          break;
        case BuildingAction.togglePumpAndLight:
          _turnOffPumpAndLight(building);
          break;
        default:
          break;
      }
    }
  }

  void _togglePump(Building building) {
    setState(() {
      building.isPumpOn = true;
      building.isLightOn = false;
    });

    // ส่งค่า pump_state ไปยัง Cloud Firestore เมื่อเปิดปั้มน้ำ
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'pump_state': 1, 'lamp_state': 0}, SetOptions(merge: true));
  }

  void _toggleLight(Building building) {
    setState(() {
      building.isPumpOn = false;
      building.isLightOn = true;
    });

    // ส่งค่า lamp_state ไปยัง Cloud Firestore เมื่อเปิดหลอดไฟ
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'pump_state': 0, 'lamp_state': 1}, SetOptions(merge: true));
  }
void _turnOffPumpAndLight(Building building) {
  setState(() {
    building.isPumpOn = false;
    building.isLightOn = false;
  });

  // ส่งค่าปิดปั้มน้ำและหลอดไฟไปยัง Cloud Firestore เมื่อถึงเวลาสิ้นสุด
  firestore
      .collection('sensor_data')
      .doc(widget.user?.uid)
      .collection('house${buildings.indexOf(building)}')
      .doc('plot')
      .set({'pump_state': 0, 'lamp_state': 0}, SetOptions(merge: true));
}

  void _togglePumpAndLight(Building building) {
    setState(() {
      building.isPumpOn = true;
      building.isLightOn = true;
    });

    // ส่งค่า pump_state และ lamp_state ไปยัง Cloud Firestore เมื่อเปิดทั้งปั้มน้ำและหลอดไฟ
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'pump_state': 1, 'lamp_state': 1}, SetOptions(merge: true));
  }

  void _turnOffPump(Building building) {
    setState(() {
      building.isPumpOn = false;
      building.isLightOn = false;
    });

    // ส่งค่าปิดปั้มน้ำไปยัง Cloud Firestore เมื่อถึงเวลาสิ้นสุด
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'pump_state': 0, 'lamp_state': 0}, SetOptions(merge: true));
  }

  void _turnOffLight(Building building) {
    setState(() {
      building.isPumpOn = false;
      building.isLightOn = false;
    });

    // ส่งค่าปิดหลอดไฟไปยัง Cloud Firestore เมื่อถึงเวลาสิ้นสุด
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'pump_state': 0, 'lamp_state': 0}, SetOptions(merge: true));
  }

  void _turnOffBuilding(Building building) {
    setState(() {
      building.isPumpOn = false;
      building.isLightOn = false;
    });

    // ส่งค่าปิดโรงเรือนไปยัง Cloud Firestore เมื่อถึงเวลาสิ้นสุด
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'pump_state': 0, 'lamp_state': 0}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตั้งเวลาเปิดปิมน้ำและหลอดไฟ'),
        backgroundColor: const Color(0xFF2F4F4F), // สีของ AppBar
      ),
      body: ListView.builder(
        itemCount: buildings.length,
        itemBuilder: (BuildContext context, int index) {
          final building = buildings[index];
          return Card(
            child: ListTile(
              title: Text(building.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('เวลาเริ่ม: ${building.startTime.format(context)}'),
                  Text('เวลาสิ้นสุด: ${building.endTime.format(context)}'),
                ],
              ),
              onTap: () async {
                await _showActionDialog(building); // แสดงก่อนที่จะตั้งเวลา
                final startTime =
                    await _selectTime(context, building.startTime);
                final endTime = await _selectTime(context, building.endTime);

                if (startTime != null && endTime != null) {
                  setState(() {
                    building.startTime = startTime;
                    building.endTime = endTime;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}

enum BuildingAction { none, togglePump, toggleLight, togglePumpAndLight }

class Building {
  final String name;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isPumpOn;
  bool isLightOn;
  BuildingAction selectedAction; // เพิ่ม selectedAction สำหรับเก็บการเลือก

  Building({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isPumpOn = false,
    this.isLightOn = false,
    this.selectedAction = BuildingAction.none, // ตั้งค่าเริ่มต้นให้เป็น none
  });
}

Future<TimeOfDay?> _selectTime(BuildContext context, TimeOfDay initialTime) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );
  return picked;
}
