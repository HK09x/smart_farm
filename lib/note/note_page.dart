import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_farm/note/add_note_page.dart';
import 'package:smart_farm/note/edit_note_page.dart';

class ViewNotesPage extends StatefulWidget {
  final User? user;

  const ViewNotesPage({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  _ViewNotesPageState createState() => _ViewNotesPageState();
}

class _ViewNotesPageState extends State<ViewNotesPage> {
  String? selectedHouse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกของคุณ'),
        backgroundColor: const Color(0xFF2F4F4F), // ตั้งสีของ AppBar ที่นี่
        actions: <Widget>[
          // DropdownButton สำหรับเลือกโรงเรือน
          DropdownButton<String>(
            value: selectedHouse,
            onChanged: (String? newValue) {
              setState(() {
                selectedHouse = newValue;
              });
            },
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'ทั้งหมด',
                child: Text('ทั้งหมด'),
              ),
              DropdownMenuItem<String>(
                value: '1',
                child: Text('โรงเรือนที่1'),
              ),
              DropdownMenuItem<String>(
                value: '2',
                child: Text('โรงเรือนที่2'),
              ),
              DropdownMenuItem<String>(
                value: '3',
                child: Text('โรงเรือนที่3'),
              ),
              DropdownMenuItem<String>(
                value: '4',
                child: Text('โรงเรือนที่4'),
              ),
              DropdownMenuItem<String>(
                value: '5',
                child: Text('โรงเรือนที่5'),
              ),
            ],
            style: const TextStyle(
                color: Colors.white), // เปลี่ยนสีตัวหนังสือของ DropdownButton
            dropdownColor:
                const Color(0xFF2F4F4F), // เปลี่ยนสีพื้นหลังของ DropdownMenu
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: selectedHouse == null || selectedHouse == 'ทั้งหมด'
            ? FirebaseFirestore.instance
                .collection('user_notes')
                .doc(widget.user?.uid)
                .collection('notes')
                .orderBy('day', descending: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('user_notes')
                .doc(widget.user?.uid)
                .collection('notes')
                .where('house', isEqualTo: selectedHouse)
                .orderBy('day', descending: true)
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('ยังไม่มีบันทึก'),
            );
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return const Center(
              child: Text('ไม่พบบันทึกสำหรับโรงเรือนที่เลือก'),
            );
          }

          // แสดงรายการบันทึกใน ListView.separated
          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              final note = notes[index];
              final day = note['day'];
              final disease = note['disease'];
              final img = note['img'];
              final house = note['house'];
              final plot = note['plot'];
              final temperature = note['temperature'];
              final humidity = note['humidity'];
              final soilMoisture = note['soil_moisture'];
              final goodVegetable = note['goodVegetable'];
              final badVegetable = note['badVegetable'];

              final formattedDate = (day as Timestamp).toDate();
              final formattedDateString =
                  "${formattedDate.day}/${formattedDate.month}/${formattedDate.year}";

              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  elevation: 4.0, // เพิ่มเงาให้กับ Card
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // ปรับรูปร่างของ Card
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        img.isNotEmpty
                            ? Container(
                                width: 170,
                                height: 190,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(img),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 100,
                                height: 100,
                              ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('วันที่: $formattedDateString'),
                              Text('โรคที่พบ: $disease'),
                              Text('โรงเรือนที่: $house'),
                              Text('แปลงผักที่: $plot'),
                              Text('อุณหภูมิ : $temperature (°C)'),
                              Text('ความชื้น : $humidity (%)'),
                              Text('ความชื้นในดิน : $soilMoisture (%)'),
                              Text('ผักที่รอด : $goodVegetable ต้น'),
                              Text('ผักที่เสีย : $badVegetable ต้น'),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (choice) {
                            if (choice == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  EditNotePage(
                                     userUid: widget.user!.uid,
                                    noteId: note.id,
                                  ),
                                ),
                              );
                            } else if (choice == 'delete') {
                              _deleteNote(note.id);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return ['edit', 'delete'].map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(
                                  choice == 'edit' ? 'แก้ไขบันทึก' : 'ลบบันทึก',
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await FirebaseFirestore.instance
          .collection('user_notes')
          .doc(widget.user?.uid)
          .collection('notes')
          .doc(noteId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกถูกลบแล้ว'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการลบบันทึก'),
        ),
      );
    }
  }
}
