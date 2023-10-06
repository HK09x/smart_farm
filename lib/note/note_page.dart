import 'package:flutter/material.dart';

class ViewNotesPage extends StatefulWidget {
  final String userUid;
  const ViewNotesPage({super.key, required this.userUid});

  @override
  State<ViewNotesPage> createState() => _ViewNotesPageState();
}

class _ViewNotesPageState extends State<ViewNotesPage> {
  String? selectedHouse; // เพิ่มตัวแปรเก็บข้อมูลของโรงเรือนที่เลือก

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}