import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
  }

  static Future<void> displayNotification(RemoteMessage message) async {
    try {
      final imageUrl = message.data['imageUrl'];
      String? imagePath;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        imagePath = await _downloadImage(imageUrl);
      }

      await _notificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'custom_notifications',
            'Custom Notifications',
            channelDescription: 'Shows custom styled notifications',
            importance: Importance.max,
            priority: Priority.high,
            largeIcon:
                imagePath != null ? FilePathAndroidBitmap(imagePath) : null,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  static Future<String> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/notif_icon.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }
}
