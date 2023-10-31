import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_farm/camera_page.dart';
import 'package:smart_farm/home_page.dart';
import 'package:smart_farm/login/change_password_page.dart';
import 'package:smart_farm/main.dart';
import 'package:smart_farm/note/note_page.dart';
import 'package:smart_farm/profile/edit_profile_page.dart';
import 'package:smart_farm/set_time_page.dart';

class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4;
  String fullName = '';
  String phoneNumber = '';
  String email = '';
  String img = '';

  @override
  void initState() {
    super.initState();

    fetchProfileData(widget.user).then((data) {
      setState(() {
        fullName = data['Full_Name'] ?? '';
        phoneNumber = data['Phone_Number'] ?? '';
        email = data['Email'] ?? '';
        img = data['img'] ?? '';
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24, // ปรับขนาดของข้อความตรงนี้
          ),
        ),
        backgroundColor: const Color(0xFF2F4F4F),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 40,
                    width: 415,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F4F4F),
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 410,
                    width: 415,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F4F4F),
                        borderRadius: BorderRadius.circular(30),
                      ),
                     
                    ),
                  ),
                  Positioned(
                    top: 35,
                    left: 40,
                    child: SizedBox(
                      height: 330,
                      width: 330,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 200,
                              width: 200,
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(
                                  image: NetworkImage(img),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Text('   '),
                                    GestureDetector(
                                      onTap: () {
                                        if (widget.user != null &&
                                            widget.user!.uid.isNotEmpty) {
                                          Clipboard.setData(ClipboardData(
                                              text: widget.user!.uid));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('คัดลอก UID สำเร็จ'),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Icon(
                                        Icons.copy,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 40,
                width: 360,
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              userProfile: {
                                'Full_Name': fullName,
                                'Phone_Number': phoneNumber,
                                'Email': email,
                                'img': img,
                              },
                              user: widget.user,
                            ),
                          ),
                        ).then((updatedProfile) {
                          if (updatedProfile != null) {
                            setState(() {
                              fullName = updatedProfile['Full_Name'] ?? '';
                              phoneNumber =
                                  updatedProfile['Phone_Number'] ?? '';
                              email = updatedProfile['Email'] ?? '';
                              img = updatedProfile['img'] ?? '';
                            });
                          }
                        });
                      },
                      child: const Row(
                        children: [
                          Text(
                            '                          แก้ข้อมูลส่วนตัว                       ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2F4F4F),
                            ),
                          ),
                          Icon(Icons.settings, color: Color(0xFF2F4F4F))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 40,
                width: 360,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Text(
                        '                          เปลี่ยนรหัสผ่าน                        ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2F4F4F),
                        ),
                      ),
                      Icon(Icons.key, color: Color(0xFF2F4F4F))
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 40,
                width: 360,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F4F4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Text(
                        '                              ออกจากระบบ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    widget.user,
                  ),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewNotesPage(user: widget.user),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraPage(user: widget.user),
                ),
              );
              break;
            case 3:
            Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetTimePage(user: widget.user),
                        ),
                      );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.user),
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
            icon: Icon(Icons.description),
            label: 'Note',
            backgroundColor: Color(0xFF2F4F4F),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
            backgroundColor: Color(0xFF2F4F4F),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_time),
            label: 'Time',
            backgroundColor: Color(0xFF2F4F4F),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Color(0xFF2F4F4F),
          ),
        ],
      ),
    );
  }
}
