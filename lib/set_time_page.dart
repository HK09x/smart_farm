import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum BuildingAction { none, togglePump, toggleLight, togglePumpAndLight }

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
    _fetchUserTimers();
    // ใน initState สร้าง Timer เพื่อตรวจสอบเวลาทุก ๆ 1 นาที
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
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

  // เมื่อผู้ใช้ตั้งค่ารายการตั้งเวลาใหม่หรือลบรายการตั้งเวลา
  // เรียก _updateUserTimers เพื่ออัปเดตข้อมูลใน Firestore
  void _onUserTimersUpdated() {
    _updateUserTimers();
  }

  Future<void> _updateUserTimers() async {
    final userTimersData = {
      'timers': buildings.map((building) {
        return {
          'name': building.name,
          'startHour': building.startTime.hour,
          'startMinute': building.startTime.minute,
          'endHour': building.endTime.hour,
          'endMinute': building.endTime.minute,
          'selectedAction': building.selectedAction.index,
        };
      }).toList(),
    };

    await firestore
        .collection('user_timers')
        .doc(widget.user?.uid)
        .set(userTimersData);
  }

  Future<void> _fetchUserTimers() async {
    final userTimersDoc =
        await firestore.collection('user_timers').doc(widget.user?.uid).get();

    if (userTimersDoc.exists) {
      final userTimersData = userTimersDoc.data() as Map<String, dynamic>;

      setState(() {
        buildings = (userTimersData['timers'] as List<dynamic>)
            .map((timerData) => Building(
                  name: timerData['name'],
                  startTime: TimeOfDay(
                      hour: timerData['startHour'],
                      minute: timerData['startMinute']),
                  endTime: TimeOfDay(
                      hour: timerData['endHour'],
                      minute: timerData['endMinute']),
                  selectedAction:
                      BuildingAction.values[timerData['selectedAction']],
                ))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel(); // ยกเลิก Timer เมื่อหน้า SetTimePage ถูก dispose
  }

  Future<TimeOfDay?> _selectTime(
      BuildContext context, TimeOfDay initialTime, String label) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      helpText: 'เลือกเวลา $label', // แสดง label ที่เพิ่มเข้ามา
      cancelText: 'ยกเลิก',
      confirmText: 'ยืนยัน',
      initialEntryMode: TimePickerEntryMode.input,
    );
    return picked;
  }

  List<Building> buildings = [
    Building(
        name: 'โรงเรือน 1',
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now(),
        selectedAction:
            BuildingAction.none), // เพิ่ม selectedAction ให้กับแต่ล่ะโรงเรือน
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
          backgroundColor: Colors.blue, // สีพื้นหลังของ AlertDialog
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16.0), // ปรับรูปร่างและขนาดของกล่อง
          ),
          title: Text(
            'เลือกการทำงานสำหรับ ${building.name}',
            style: const TextStyle(
                color: Colors.white), // สีของข้อความใน AlertDialog
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // ปรับรูปร่างและขนาดของตัวเลือก
                  ),
                  title: const Text(
                    'เปิดปั้มน้ำอย่างเดียว',
                    style: TextStyle(color: Colors.white), // สีของตัวเลือก
                  ),
                  onTap: () {
                    Navigator.of(context).pop(BuildingAction.togglePump);
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // ปรับรูปร่างและขนาดของตัวเลือก
                  ),
                  title: const Text(
                    'เปิดหลอดไฟอย่างเดียว',
                    style: TextStyle(color: Colors.white), // สีของตัวเลือก
                  ),
                  onTap: () {
                    Navigator.of(context).pop(BuildingAction.toggleLight);
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // ปรับรูปร่างและขนาดของตัวเลือก
                  ),
                  title: const Text(
                    'เปิดทั้งปั้มน้ำและหลอดไฟ',
                    style: TextStyle(color: Colors.white), // สีของตัวเลือก
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pop(BuildingAction.togglePumpAndLight);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ButtonBar(
              children: [
                TextButton(
                  child: const Text('ยกเลิก',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                  onPressed: () {
                    Navigator.of(context).pop(BuildingAction.none);
                  },
                ),
              ],
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

void _showActionAndTimingDialog(Building building) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('เลือกการทำงานและเวลาสำหรับ ${building.name}'),
        content: Column(
          children: [
            ListTile(
              title: Text('เปิดปั้มน้ำอย่างเดียว'),
              onTap: () {
                setState(() {
                  building.selectedAction = BuildingAction.togglePump;
                });
                Navigator.of(context).pop();

                // ใช้ TimeOfDay.now() เพื่อตั้งค่า initialTime เป็นเวลาปัจจุบัน
                _selectTimeForBuilding(building, TimeOfDay.now(), TimeOfDay.now());
              },
            ),
            ListTile(
              title: Text('เปิดหลอดไฟอย่างเดียว'),
              onTap: () {
                setState(() {
                  building.selectedAction = BuildingAction.toggleLight;
                });
                Navigator.of(context).pop();

                // ใช้ TimeOfDay.now() เพื่อตั้งค่า initialTime เป็นเวลาปัจจุบัน
                _selectTimeForBuilding(building, TimeOfDay.now(), TimeOfDay.now());
              },
            ),
            ListTile(
              title: Text('เปิดทั้งปั้มน้ำและหลอดไฟ'),
              onTap: () {
                setState(() {
                  building.selectedAction = BuildingAction.togglePumpAndLight;
                });
                Navigator.of(context).pop();

                // ใช้ TimeOfDay.now() เพื่อตั้งค่า initialTime เป็นเวลาปัจจุบัน
                _selectTimeForBuilding(building, TimeOfDay.now(), TimeOfDay.now());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('ยกเลิก',style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _selectTimeForBuilding(
    Building building, TimeOfDay startTime, TimeOfDay endTime) async {
  final TimeOfDay? newStartTime = await _selectTime(
    context,
    startTime,
    'เริ่มต้น',
  );
  if (newStartTime != null) {
    setState(() {
      building.startTime = newStartTime;
    });
  }

  final TimeOfDay? newEndTime = await _selectTime(
    context,
    endTime,
    'สิ้นสุด',
  );
  if (newEndTime != null) {
    setState(() {
      building.endTime = newEndTime;
    });
  }
}



  void _performSelectedAction(Building building) {
    final now = TimeOfDay.now();

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

    // ส่งค่าปิดปั้มน้ำและหลอดไฟไปยัง Cloud Firestore เมื่อเปิดทั้งปั้มน้ำและหลอดไฟ
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
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

    // ส่งค่า lamp_state และ pump_state ไปยัง Cloud Firestore เมื่อเปิดทั้งปั้มน้ำและหลอดไฟ
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'pump_state': 1, 'lamp_state': 1}, SetOptions(merge: true));
  }

  void _turnOffBuilding(Building building) {
    setState(() {
      building.isPumpOn = false;
      building.isLightOn = false;
      building.selectedAction = BuildingAction.none;
    });

    // ส่งค่าปิดทุกอย่างไปยัง Cloud Firestore เมื่อถึงเวลาสิ้นสุด
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'pump_state': 0, 'lamp_state': 0}, SetOptions(merge: true));
  }

  void _turnOffPump(Building building) {
    setState(() {
      building.isPumpOn = false;
    });

    // ส่งค่าปิดปั้มน้ำไปยัง Cloud Firestore เมื่อถึงเวลาสิ้นสุด
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'pump_state': 0}, SetOptions(merge: true));
  }

  void _turnOffLight(Building building) {
    setState(() {
      building.isLightOn = false;
    });

    // ส่งค่าปิดหลอดไฟไปยัง Cloud Firestore เมื่อถึงเวลาสิ้นสุด
    // ใช้ index ของโรงเรือนในการสร้างเส้นทาง
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection('house${buildings.indexOf(building)}')
        .doc('plot')
        .set({'lamp_state': 0}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ตั้งค่าเวลา'),
          backgroundColor: const Color(0xFF2F4F4F), // ตั้งสีของ AppBar ที่นี่
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'บันทึก',
              onPressed: () {
                _onUserTimersUpdated();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('บันทึกสำเร็จ')),
                );
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: buildings.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  'เวลาสำหรับ ${buildings[index].name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'ตั้งแต่ ${buildings[index].startTime.format(context)} ถึง ${buildings[index].endTime.format(context)}\n'
                  'สถานะ: ${_getActionText(buildings[index])}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.access_alarm),
                  tooltip: 'แก้ไขการทำงาน',
                  onPressed: () {
                    _showActionAndTimingDialog(buildings[index]);
                  },
                ),
                onTap: () {
                  // เพิ่มโค้ดเมื่อแตะที่แถวเพื่อเลือกเวลาหรือแก้ไข
                  _showActionAndTimingDialog(buildings[index]);
                },
              ),
            );
          },
        ));
  }

  String _getActionText(Building building) {
    switch (building.selectedAction) {
      case BuildingAction.togglePump:
        return 'เปิดปั้มน้ำอย่างเดียว';
      case BuildingAction.toggleLight:
        return 'เปิดหลอดไฟอย่างเดียว';
      case BuildingAction.togglePumpAndLight:
        return 'เปิดทั้งปั้มน้ำและหลอดไฟ';
      default:
        return 'ไม่มีการทำงาน';
    }
  }
}

class Building {
  final String name;
  TimeOfDay startTime;
  TimeOfDay endTime;
  BuildingAction selectedAction;
  bool isPumpOn;
  bool isLightOn;

  Building({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.selectedAction,
    this.isPumpOn = false,
    this.isLightOn = false,
  });
}
