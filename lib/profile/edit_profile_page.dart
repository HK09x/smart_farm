import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  final User? user;

  const EditProfilePage(
      {Key? key, required this.userProfile, required this.user})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? imgURL;
  File? pickedImage;

  @override
  void initState() {
    super.initState();

    _fullNameController.text = widget.userProfile['Full_Name'] ?? '';
    _phoneNumberController.text = widget.userProfile['Phone_Number'] ?? '';
    _emailController.text = widget.userProfile['Email'] ?? '';
    imgURL = widget.userProfile['img'];
  }

  Future<String> _uploadImage(File imageFile) async {
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${widget.user?.uid}')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final UploadTask uploadTask = storageReference.putFile(imageFile);

    final TaskSnapshot downloadUrl = await uploadTask;
    final String url = await downloadUrl.ref.getDownloadURL();

    setState(() {
      imgURL = url;
    });

    return url;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _showImageSourceSelectionDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกแหล่งที่มาของรูปภาพ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop('Gallery');
                  },
                  child: const ListTile(
                    leading: Icon(Icons.photo),
                    title: Text('เลือกจากแกลเรียม'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop('Camera');
                  },
                  child: const ListTile(
                    leading: Icon(Icons.camera),
                    title: Text('ถ่ายรูป'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2F4F4F), // สีของ AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: InkWell(
                onTap: () async {
                  final action = await _showImageSourceSelectionDialog();
                  if (action == 'Gallery') {
                    _pickImage();
                  } else if (action == 'Camera') {
                    _takePicture();
                  }
                },
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F4F4F), // สีพื้นหลังของปุ่ม
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 36.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Text(
              'ชื่อ:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Color(0xFF2F4F4F), // สีของข้อความ
              ),
            ),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'กรอกชื่อ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'เบอร์โทร:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Color(0xFF2F4F4F),
              ),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: 'กรอกเบอร์โทร',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'อีเมล:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Color(0xFF2F4F4F),
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'กรอกอีเมล',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
           Center(
  child: ElevatedButton(
    onPressed: () async {
      final updatedProfile = {
        'Full_Name': _fullNameController.text,
        'Phone_Number': _phoneNumberController.text,
        'Email': _emailController.text,
        'img': imgURL,
      };

      final User? user = widget.user;
      final String uid = user?.uid ?? '';

      if (pickedImage != null) {
        final imageUrl = await _uploadImage(pickedImage!);
        updatedProfile['img'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(updatedProfile);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2F4F4F), // สีพื้นหลังของปุ่ม
    ),
    child: const Text(
      'บันทึก',
      style: TextStyle(fontSize: 18.0),
    ),
  ),
)

          ],
        ),
      ),
    );
  }
}
