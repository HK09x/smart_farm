import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraPage extends StatefulWidget {
  final User? user;

  const CameraPage({Key? key, this.user}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  Stream<DocumentSnapshot>? getSensorData(String houseName) {
    return FirebaseFirestore.instance
        .collection('sensor_data')
        .doc(widget.user!.uid)
        .collection(houseName)
        .doc('plot')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('กล้อง'),
        backgroundColor: const Color(0xFF2F4F4F),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                for (var houseIndex = 0; houseIndex < 5; houseIndex++)
                  StreamBuilder<DocumentSnapshot>(
                    stream: getSensorData('house$houseIndex'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(
                          child: Text(
                              'ไม่พบข้อมูลหรือเกิดข้อผิดพลาดในการดึงข้อมูล'),
                        );
                      } else {
                        var data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        String? webViewData = data['ip'];
                        String houseName =
                            'โรงเรือน ${houseIndex + 1}'; // เพิ่มชื่อโรงเรือนที่นี่

                        return SizedBox(
                          width: 380,
                          height: 300,
                          child: Card(
                            color: Color.fromARGB(255, 80, 100, 100),
                            elevation: 4,
                            margin: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: WebView(
                                    initialUrl:
                                        Uri.encodeComponent(webViewData ?? ''),
                                    javascriptMode: JavascriptMode.unrestricted,
                                  ),
                                ),
                                const SizedBox(height: 9.0),
                                Row(
                                  children: [
                                    SizedBox(width: 10,),
                                    const Icon(
                                      Icons.camera,
                                      size: 40.0,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      houseName, // แสดงชื่อโรงเรือนที่นี่
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 9.0),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
