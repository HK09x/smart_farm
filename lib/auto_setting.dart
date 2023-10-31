import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutoSetting extends StatefulWidget {
  final User? user;
  final String houseName;

  const AutoSetting({Key? key, this.user, required this.houseName})
      : super(key: key);

  @override
  State<AutoSetting> createState() => _AutoSettingState();
}

class _AutoSettingState extends State<AutoSetting> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  double humidity = 0.0; // ตัวแปรสำหรับความชื้น
  double soilMoisture = 0.0; // ตัวแปรสำหรับความชื้นในดิน
  double temperature = 0.0; // ตัวแปรสำหรับอุณหภูมิ

  @override
  void initState() {
    super.initState();
    _startMoistureMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่าการทำงานอัตโนมัติ'),
        backgroundColor: const Color(0xFF2F4F4F),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<DocumentSnapshot>(
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
                soilMoisture =
                    (data['soilMoisture'] as num?)?.toDouble() ?? 0.0;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 180,
                      width: 180,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F4F4F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 60,
                            width: 60,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                image: AssetImage('images/ชื้นดิน.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'ความชื้นในดิน',
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
                ],
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F4F4F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              _showThresholdDialog();
            },
            child: const Text(
              'ปรับค่าความชื้นในดิน',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showThresholdDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double newThreshold = 0.0; // ค่าความชื้นใหม่ที่ผู้ใช้ต้องการ
        return AlertDialog(
          title: const Text('ตั้งค่าความชื้นในดิน'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newThreshold = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            TextButton(
              onPressed: () {
                if (newThreshold >= 0.0) {
                  _updateSoilMoistureThreshold(newThreshold);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ค่าความชื้นในดินต้องเป็นตัวเลขบวก'),
                    ),
                  );
                }
              },
              child: const Text(
                'บันทึก',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _startMoistureMonitoring() {
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection(widget.houseName)
        .doc('plot')
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final currentSoilMoisture = data['soilMoisture'] as num?;
        final userSetThreshold = data['soilMoistureThreshold'] as num?;

        if (currentSoilMoisture != null && userSetThreshold != null) {
          if (currentSoilMoisture <= userSetThreshold) {
            _turnOnPump();
          } else {
            _turnOffPump();
          }
        }
      }
    });
  }

  void _updateSoilMoistureThreshold(double newThreshold) {
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection(widget.houseName)
        .doc('plot')
        .set({'soilMoistureThreshold': newThreshold}, SetOptions(merge: true));
  }

  void _turnOnPump() {
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection(widget.houseName)
        .doc('plot')
        .set({'pump_state': 1}, SetOptions(merge: true));
  }

  void _turnOffPump() {
    firestore
        .collection('sensor_data')
        .doc(widget.user?.uid)
        .collection(widget.houseName)
        .doc('plot')
        .set({'pump_state': 0}, SetOptions(merge: true));
  }
}
