import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetTimePage extends StatefulWidget {
  final User? user;
  const SetTimePage({super.key, this.user});

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
          _togglePump(building);
          _toggleLight(building);
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
        endTime: TimeOfDay.now()),
    Building(
        name: 'โรงเรือน 2',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now()),
    Building(
        name: 'โรงเรือน 3',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now()),
    Building(
        name: 'โรงเรือน 4',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now()),
    Building(
        name: 'โรงเรือน 5',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now()),
  ];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void _togglePump(Building building) {
    setState(() {
      building.isPumpOn = !building.isPumpOn;
    });

    // ส่งค่า pump_state ไปยัง Cloud Firestore เมื่อเปิดหรือปิดปั้มน้ำ
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set(
            {'pump_state': building.isPumpOn ? 1 : 0}, SetOptions(merge: true));
  }

  void _toggleLight(Building building) {
    setState(() {
      building.isLightOn = !building.isLightOn;
    });

    // ส่งค่า lamp_state ไปยัง Cloud Firestore เมื่อเปิดหรือปิดหลอดไฟ
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'lamp_state': building.isLightOn ? 1 : 0},
            SetOptions(merge: true));
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

extension TimeOfDayExtension on TimeOfDay {
  String format(BuildContext context) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, this.hour, this.minute);
    final formatter = MaterialLocalizations.of(context).formatTimeOfDay(this);
    return formatter;
  }
}

Future<TimeOfDay?> _selectTime(
    BuildContext context, TimeOfDay initialTime) async {
  return await showTimePicker(
    context: context,
    initialTime: initialTime,
  );
}

class Building {
  final String name;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isPumpOn;
  bool isLightOn;

  Building({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isPumpOn = false,
    this.isLightOn = false,
  });
}
