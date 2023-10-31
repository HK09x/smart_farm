import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddNotePage extends StatefulWidget {
  final String userUid;
  const AddNotePage({super.key, required this.userUid});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _plotController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _soilMoistureController = TextEditingController();
  final TextEditingController _goodVegetableController =
      TextEditingController(); // ช่องใส่จำนวนผักที่ดี
  final TextEditingController _badVegetableController =
      TextEditingController(); // ช่องใส่จำนวนผักที่เสีย
  File? pickedImage;
  DateTime? selectedDate;
  String? _currentImageUrl;
  void _addNote() async {
    final Timestamp dayTimestamp = selectedDate != null
        ? Timestamp.fromDate(selectedDate!)
        : Timestamp.now();
    final String disease = _diseaseController.text.trim();
    final String house = _houseController.text.trim();
    final String plot = _plotController.text.trim();
    final String temperature = _temperatureController.text.trim();
    final String humidity = _humidityController.text.trim();
    final String soilMoisture = _soilMoistureController.text.trim();
    final String goodVegetable =
        _goodVegetableController.text.trim(); // จำนวนผักที่ดี
    final String badVegetable =
        _badVegetableController.text.trim(); // จำนวนผักที่เสีย

    if (disease.isNotEmpty &&
        house.isNotEmpty &&
        plot.isNotEmpty &&
        temperature.isNotEmpty &&
        humidity.isNotEmpty &&
        soilMoisture.isNotEmpty) {
      // Upload the image (if available) to Firebase Storage
      String imageUrl = '';
      if (pickedImage != null) {
        imageUrl = await _uploadImage(pickedImage!);
      }

      // Add the note to Firestore, including the image URL
      FirebaseFirestore.instance
          .collection('user_notes')
          .doc(widget.userUid)
          .collection('notes')
          .add({
        'day': dayTimestamp,
        'disease': disease,
        'img': imageUrl,
        'house': house,
        'plot': plot,
        'temperature': temperature,
        'humidity': humidity,
        'soil_moisture': soilMoisture,
        'goodVegetable': goodVegetable, // จำนวนผักที่ดี
        'badVegetable': badVegetable, // จำนวนผักที่เสีย
      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred while adding the note.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(widget.userUid)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final UploadTask uploadTask = storageReference.putFile(imageFile);

    final TaskSnapshot downloadUrl = await uploadTask;
    final String url = await downloadUrl.ref.getDownloadURL();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 57,
                  width: 415,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F4F4F),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BackButton(
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Container(
  padding: const EdgeInsets.all(0),
  height: 200,
  width: 1000,
  decoration: BoxDecoration(
    color: Colors.grey,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Stack(
    children: [
      if (_currentImageUrl != null)
        Positioned.fill(
          child: Image.network(
            _currentImageUrl!,
            fit: BoxFit.cover, // ให้รูปภาพปรับขนาดเพื่อเต็มพื้นที่
          ),
        ),
      if (pickedImage != null)
        Positioned.fill(
          child: Image.file(
            pickedImage!,
            fit: BoxFit.cover, // ให้รูปภาพปรับขนาดเพื่อเต็มพื้นที่
          ),
        ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(0),
          height: 40,
          width: 400,
          decoration: BoxDecoration(
            color: const Color(0xFF2F4F4F),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Center(
            child: Row(
              children: [
                const Spacer(),
                Expanded(
                  child: TextButton(
                  onPressed: () async {
                    _takePicture();
                  },
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                  ),
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: TextButton(
                  onPressed: () async {
                    _pickImage();
                  },
                  child: const Icon(
                    Icons.picture_in_picture_outlined,
                    color: Colors.white,
                  ),
                  ),
                ),
                const Spacer()
              ],
            ),
          ),
        ),
      ),
    ],
  ),
),

                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        onPressed: () {
                          _selectDate(
                              context); // เรียกใช้งานฟังก์ชันเพื่อเลือกวันที่
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today, // ไอคอนของปฏิทิน
                              color: Colors.blue, // สีของไอคอน
                            ),
                            const SizedBox(
                                width: 8), // ระยะห่างระหว่างไอคอนและข้อความ
                            Text(
                              selectedDate != null
                                  ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}" // แสดงวันที่ที่ถูกเลือก
                                  : "เลือกวันที่", // ถ้ายังไม่ได้เลือกวันที่
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors
                                    .blue, // สีของข้อความเมื่อเลือกวันที่
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextField(
                        controller: _houseController,
                        decoration: InputDecoration(
                          labelText: 'โรงเรือนที่ปลูก',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                        onChanged: (houseName) {
                          _fetchSensorDataForHouse(houseName);
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: _plotController,
                        decoration: InputDecoration(
                          labelText: 'แปลงที่ปลูก',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: _temperatureController,
                        decoration: InputDecoration(
                          labelText: 'ค่าอุณหภูมิ   (°C)',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: _humidityController,
                        decoration: InputDecoration(
                          labelText: 'ค่าความชื่น  (%)',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: _soilMoistureController,
                        decoration: InputDecoration(
                          labelText: 'ค่าความชื่นในดิน  (%)',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: _diseaseController,
                        decoration: InputDecoration(
                          labelText: 'การสำรวจโรค',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: _goodVegetableController,
                        decoration: InputDecoration(
                          labelText: 'จำนวนผักที่รอด',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: _badVegetableController,
                        decoration: InputDecoration(
                          labelText: 'จำนวนผักที่ตาย',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 40,
                        width: 375,
                        //width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F4F4F),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          onPressed: _addNote,
                          child: const Text(
                            '               บันทึก                ',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Future<void> _fetchSensorDataForHouse(String houseNumber) async {
    String collectionName = '';

    // แปลงเลขที่ผู้ใช้ป้อนใน TextField เป็นชื่อ Collection
    switch (houseNumber) {
      case '1':
        collectionName = 'house0';
        break;
      case '2':
        collectionName = 'house1';
        break;
      case '3':
        collectionName = 'house2';
        break;
      case '4':
        collectionName = 'house3';
        break;
      case '5':
        collectionName = 'house4';
        break;
      // คุณอาจจะต้องเพิ่มเงื่อนไขเพิ่มเติมหากต้องการรองรับค่าเลขอื่น ๆ
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sensor_data')
          .doc(widget.userUid)
          .collection(collectionName)
          .doc('plot')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        setState(() {
          _temperatureController.text = data['temperature'].toString();
          _humidityController.text = data['humidity'].toString();
          _soilMoistureController.text = data['soilMoisture'].toString();
        });
      }
    // ignore: empty_catches
    } catch (e) {
    }
  }
}
