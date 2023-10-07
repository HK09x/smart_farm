import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditNotePage extends StatefulWidget {
  final String userUid;
  final String noteId;

  const EditNotePage({
    Key? key,
    required this.userUid,
    required this.noteId,
  }) : super(key: key);

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _plotController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _soilMoistureController = TextEditingController();
  final TextEditingController _goodVegetableController =
      TextEditingController();
  final TextEditingController _badVegetableController = TextEditingController();
  
  File? pickedImage;
  String? _currentImageUrl;
  DateTime? selectedDate;
  

  @override
  void initState() {
    super.initState();
    _loadNoteData();
  }

  void _loadNoteData() async {
    try {
      final noteSnapshot = await FirebaseFirestore.instance
          .collection('user_notes')
          .doc(widget.userUid)
          .collection('notes')
          .doc(widget.noteId)
          .get();

      if (noteSnapshot.exists) {
        final noteData = noteSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _diseaseController.text = noteData['disease'];
          _houseController.text = noteData['house'];
          _plotController.text = noteData['plot'];
          _temperatureController.text = noteData['temperature'].toString();
          _humidityController.text = noteData['humidity'].toString();
          _soilMoistureController.text = noteData['soil_moisture'].toString();
          _goodVegetableController.text = noteData['goodVegetable'].toString();
          _badVegetableController.text = noteData['badVegetable'].toString();
          selectedDate = (noteData['day'] as Timestamp).toDate();
           _currentImageUrl = noteData['img'];
          _loadCurrentImageUrl();
        });
      }
    } catch (error) {
      print('Error loading note data: $error');
    }
  }

  void _loadCurrentImageUrl() async {
    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(widget.userUid)
          .child('${widget.noteId}.jpg');

      final url = await storageReference.getDownloadURL();

      setState(() {
        _currentImageUrl = url;
      });
    } catch (error) {
      print('Error loading current image URL: $error');
    }
  }

  void _editNote() async {
  final Timestamp dayTimestamp = selectedDate != null
      ? Timestamp.fromDate(selectedDate!)
      : Timestamp.now();
  final String disease = _diseaseController.text.trim();
  final String house = _houseController.text.trim();
  final String plot = _plotController.text.trim();
  final String temperature = _temperatureController.text.trim();
  final String humidity = _humidityController.text.trim();
  final String soilMoisture = _soilMoistureController.text.trim();
  final String goodVegetable = _goodVegetableController.text.trim();
  final String badVegetable = _badVegetableController.text.trim();

  if (disease.isNotEmpty &&
      house.isNotEmpty &&
      plot.isNotEmpty &&
      temperature.isNotEmpty &&
      humidity.isNotEmpty &&
      soilMoisture.isNotEmpty) {
    String imageUrl = '';

    // เพิ่มเงื่อนไขเช็คว่า pickedImage ไม่เท่ากับ null ก่อนที่จะอัปโหลดรูปภาพใหม่
    if (pickedImage != null) {
      imageUrl = await _uploadImage(pickedImage!);
    } else if (_currentImageUrl != null) {
      // ถ้าไม่ได้เปลี่ยนรูปภาพแต่มีรูปภาพปัจจุบัน (URL ไม่ใช่ null) ให้ใช้ URL รูปภาพปัจจุบัน
      imageUrl = _currentImageUrl!;
    }

    try {
      await FirebaseFirestore.instance
          .collection('user_notes')
          .doc(widget.userUid)
          .collection('notes')
          .doc(widget.noteId)
          .update({
        'day': dayTimestamp,
        'disease': disease,
        'img': imageUrl,
        'house': house,
        'plot': plot,
        'temperature': temperature,
        'humidity': humidity,
        'soil_moisture': soilMoisture,
        'goodVegetable': goodVegetable,
        'badVegetable': badVegetable,
      });

      Navigator.pop(context);
    } catch (error) {
      print('Error updating note: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while updating the note.'),
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
    }
  }
}

  Future<String> _uploadImage(File imageFile) async {
    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(widget.userUid)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final UploadTask uploadTask = storageReference.putFile(imageFile);

      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();
      return url;
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

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
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(0),
                          height: 130,
                          width: 1000,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              if (_currentImageUrl != null)
                                Image.network(_currentImageUrl!),
                              if (pickedImage != null) Image.file(pickedImage!),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(0),
                                  height: 40,
                                  width: 371,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2F4F4F),
                                    borderRadius: BorderRadius.circular(16),
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
                            _selectDate(context);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedDate != null
                                    ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                    : "เลือกวันที่",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
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
                            labelText: 'ค่าอุณหภูมิ (°C)',
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
                            labelText: 'ค่าความชื้น (%)',
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
                            labelText: 'ค่าความชื้นในดิน (%)',
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: const Color(0xFF2F4F4F),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            onPressed: _editNote,
                            child: const Text(
                              '               บันทึก                ',
                              style: TextStyle(fontSize: 20),
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
      ),
    );
  }

  Future<void> _fetchSensorDataForHouse(String houseNumber) async {
    String collectionName = '';

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
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }
}
