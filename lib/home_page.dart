import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_farm/edit_Info.dart';
import 'package:smart_farm/house_page.dart';
import 'package:smart_farm/main.dart';
import 'package:smart_farm/note/note_page.dart';
import 'package:smart_farm/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  final User? user;

  HomePage(this.user, {Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final img = '';
  int _currentIndex = 0;
  String fullName = '';
  String info = ''; // เปลี่ยนให้ info เป็น String

  // สร้างฟังก์ชันเพื่ออัปเดตค่า info ใน State ของ HomePage
  void updateInfo(String updatedInfo) {
    setState(() {
      info = updatedInfo;
    });
  }

  Future<Map<String, dynamic>> fetchProfileData(User? user) async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data;
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const LoginPage();
    } else {
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 230,
                    width: 440.4,
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F4F4F),
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  Container(
                    height: 70,
                    width: 440.4,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 440.4,
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  const Positioned(
                    top: 20,
                    child: Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Container(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: fetchProfileData(widget.user),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('ไม่พบข้อมูลโปรไฟล์');
                        } else {
                          final data = snapshot.data!;
                          final img = data['img'] ?? '';
                          fullName = data['Full_Name'] ?? '';

                          return Positioned(
                            top: 70,
                            left: 20,
                            child: Container(
                              height: 70,
                              width: 70,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    img,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: fetchProfileData(widget.user),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('ไม่พบข้อมูลโปรไฟล์');
                        } else {
                          final data = snapshot.data!;

                          fullName = data['Full_Name'] ?? '';

                          return Positioned(
                            top: 90,
                            left: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello   ${widget.user?.displayName ?? fullName}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final houseName = 'house$index';

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('sensor_data')
                          .doc(widget.user?.uid)
                          .collection(houseName)
                          .doc('plot')
                          .snapshots(),
                      builder: (context, snapshot) {
                        var info = snapshot.data?.get('info') ?? '';
                        return FractionallySizedBox(
                          widthFactor: 0.8,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 5,
                            margin: const EdgeInsets.all(10),
                            color: const Color(0xFF2F4F4F),
                            child: Container(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        index == 0
                                            ? 'โรงเรือนที่ 1'
                                            : 'โรงเรือนที่ ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final updatedInfo =
                                              await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditInfoPage(
                                                initialInfo: info,
                                                user: widget.user,
                                                houseName: houseName,
                                                updateInfo: updateInfo,
                                              ),
                                            ),
                                          );

                                          if (updatedInfo != null) {
                                            updateInfo(
                                                updatedInfo); // อัปเดตค่า info ใน State ของ HomePage
                                          }
                                        },
                                        child: Text(
                                          'จำนวนต้น: $info',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HousePage(
                                        user: widget.user,
                                        houseNumber: index,
                                        houseName: houseName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 35,
                width: 375,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F4F4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewNotesPage(userUid: widget.user?.uid ?? ""),
                      ),
                    );
                  },
                  child: const Text(
                    'บันทึกผลประจำวัน',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  switch (index) {
                    case 0:
                      // เส้นทางสำหรับไอคอน "หน้าหลัก"
                      break;
                    case 1:
                      // เส้นทางสำหรับไอคอน "Note"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewNotesPage(
                            userUid: '',
                          ),
                        ),
                      );
                      break;
                    case 2:
                      // เส้นทางสำหรับไอคอน "Camera"
                      break;
                    case 3:
                      // เส้นทางสำหรับไอคอน "ค้นหา"
                      break;
                    case 4:
                      // เส้นทางสำหรับไอคอน "โปรไฟล์"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilPage(),
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
              )
            ],
          ),
        ),
      );
    }
  }
}
