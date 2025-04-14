import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/notifications/serverkey.dart';
import 'package:flutter_recipe_app/providers/notificationpush.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

Future<void> recordFollowNotification({
  required String targetUserId,
  required String senderId,
  required BuildContext context,
}) async {
  try {
    final senderDoc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(senderId)
            .get();
    if (!senderDoc.exists) return;

    final fullName = senderDoc['fullNames'] ?? 'Someone';
    final profilePhoto =
        senderDoc['profilePhoto'] ?? 'https://picsum.photos/300/200';

    debugPrint('profilephoto url  $profilePhoto');

    final fcmTokens = await _getAllFcmTokens(targetUserId);
    if (fcmTokens.isEmpty) return;

    final notificationRef =
        FirebaseFirestore.instance
            .collection('Notifications')
            .doc(targetUserId)
            .collection('userNotifications')
            .doc();

    await notificationRef.set({
      'isRead': false,
      'sender': senderId,
      'time': FieldValue.serverTimestamp(),
      'type': 'follow',
      'notificationId': notificationRef.id,
    });

   

    for (final token in fcmTokens) {
      await _sendPushNotification(
        fcmToken: token,
        imageurl: profilePhoto,
        senderId: senderId,
        title: fullName,
        body: 'is now following you',
        data: {'senderId': senderId, 'type': 'follow'},
      );
    }
  } catch (e, stackTrace) {
    debugPrint('Notification Error: $e\n$stackTrace');
  }
}

Future<List<String>> _getAllFcmTokens(String userId) async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('devices')
          .get();

  return snapshot.docs
      .map((doc) => doc['fcmToken'] as String?)
      .where((token) => token != null)
      .cast<String>()
      .toList();
}

Future<void> _sendPushNotification({
  required String fcmToken,
  required String title,
  required String imageurl,
  required String senderId,
  required String body,
  required Map<String, dynamic> data,
}) async {
  const projectId = 'flutter-recipe-app-6b63e';
  final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await GetServerKey().serverToken()}',
      },
      body: jsonEncode({
        "message": {
          "token": fcmToken,
          "data": {
            "type": "follow",
            "sender": senderId,
            "time": DateTime.now().toIso8601String(),
            "productInfo": "",
          },
          "notification": {"title": title, "body": body, "image": imageurl},
          "android": {
            "priority": "high",
            "notification": {
              "image": imageurl,
              "channel_id": "follow_notifications",
              "notification_priority": "PRIORITY_MAX",
            },
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Notification sent successfully!');
    } else {
      debugPrint('❌ Failed to send notification: ${response.body}');
    }
  } catch (e) {
    debugPrint('‼️ Notification error: $e');
  }
}

Future<void> recordLikedNotification({
  required String targetUserId,
  required String senderId,
  required String recipeId,
  required BuildContext context,
}) async {
  final docRef = await FirebaseFirestore.instance
      .collection('Notifications')
      .doc(targetUserId)
      .collection('userNotifications')
      .add({
        'isRead': false,
        'sender': senderId,
        'time': FieldValue.serverTimestamp(),
        'type': 'liked',
        'recipeId': recipeId,
      });

  if (context.mounted &&
      targetUserId == FirebaseAuth.instance.currentUser?.uid) {
    final notification = await docRef.get();
    Provider.of<PushNotificationProvider>(
      context,
      listen: false,
    ).showNotificationDialog(
      context: context,
      notificationData: notification.data()!,
    );
  }
}

Future<void> recordNewRecipeNotification({
  required String followerId,
  required String senderId,
  required String recipeId,
  required BuildContext context,
}) async {
  final docRef =
      FirebaseFirestore.instance
          .collection('Notifications')
          .doc(followerId)
          .collection('userNotifications')
          .doc();

  await docRef.set({
    'isRead': false,
    'sender': senderId,
    'time': FieldValue.serverTimestamp(),
    'type': 'new_recipe',
    'recipeId': recipeId,
  });

  if (context.mounted && followerId == FirebaseAuth.instance.currentUser?.uid) {
    final notification = await docRef.get();
    Provider.of<PushNotificationProvider>(
      context,
      listen: false,
    ).showNotificationDialog(
      context: context,
      notificationData: notification.data()!,
    );
  }
}
