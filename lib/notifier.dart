import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void checkSoilMoistureAndNotify(User? user, String houseName) {
  FirebaseFirestore.instance
      .collection('sensor_data')
      .doc(user?.uid)
      .collection("house0")
      .doc('plot')
      .snapshots()
      .listen((snapshot) {
    if (snapshot.exists) {
      final soilMoisture = snapshot.data()?['soilMoisture'] ?? 0;
      final soilMoistureThreshold =
          snapshot.data()?['soilMoistureThreshold'] ?? 0;

      if (soilMoisture < soilMoistureThreshold) {
        // Create a notification
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.max,
          priority: Priority.high,
          ongoing:
              true, // ตั้งค่าให้เป็น true เพื่อทำให้การแจ้งเตือนเป็น "persistent"
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        _showSoilMoistureNotification(flutterLocalNotificationsPlugin,
            platformChannelSpecifics, soilMoisture);
      }
    }
  });
}

Future<void> _showSoilMoistureNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    NotificationDetails platformChannelSpecifics,
    int soilMoisture) async {
  await flutterLocalNotificationsPlugin.show(
    0,
    'ความชื้นในดินต่ำ',
    'ความชื้นในดินต่ำเกินไป: $soilMoisture',
    platformChannelSpecifics,
    payload: 'item x',
  );
}
