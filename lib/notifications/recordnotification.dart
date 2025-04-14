import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/notifications/serverkey.dart';

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

        collapseKey: '',
        senderId: senderId,

        data: {
          'sender': senderId,
          'type': 'follow',
          'time': DateTime.now().toIso8601String(),
          'productInfo': '',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'title': fullName,
          'body': 'is now following you',
          'imageurl': profilePhoto,
          'collapseKey': '',
        },
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

  required String senderId,
  required String collapseKey,

  required Map<String, dynamic> data,
}) async {
  const projectId = 'flutter-recipe-app-6b63e';
  final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

  debugPrint('collapse_key $collapseKey');

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

          "data": data,
          "android": {
           
            "priority": "high",
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
  try {
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

    final userIds = await fetchNotificationDocUserIds(recipeId);
    // debugPrint('Fetched userIds: $userIds');

    final users = await fetchUserNamesAndPhotos(userIds);

    debugPrint('got users $users');

    String body;
    if (userIds.length == 1) {
      body = '${users[0]['name']} liked your recipe';
    } else if (userIds.length == 2) {
      body = '${users[0]['name']}, ${users[1]['name']} liked your recipe';
    } else {
      body =
          '${users[0]['name']}, ${users[1]['name']} and ${userIds.length - 2} others liked your recipe';
    }

    debugPrint(
      'firstimageurl ${users.first['photo'] ?? ''}     and  secondimageurl ',
    );

    final fcmTokens = await _getAllFcmTokens(targetUserId);
    for (final token in fcmTokens) {
      await _sendPushNotification(
        fcmToken: token,
        senderId: senderId,

        collapseKey: recipeId,

        data: {
          'type': 'liked',
          'time': DateTime.now().toIso8601String(),
          'userIds': userIds.join(','),
          'productInfo': recipeId,
          'sender': senderId,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'title': 'New Like',
          'body': body,
          'imageurl1': users.first['photo'] ?? '',
          'imageurl2': userIds.length > 1 ? users[1]['photo'] ?? '' : '',
          'collapseKey': recipeId.trim(),
        },
      );
    }
  } catch (e) {
    debugPrint('recordLikedNotification error: $e');
  }
}

Future<List<String>> fetchNotificationDocUserIds(String recipeId) async {
  final snapshot =
      await FirebaseFirestore.instance
          .collectionGroup('userNotifications')
          .where('type', isEqualTo: 'liked')
          .where('recipeId', isEqualTo: recipeId)
          .get();

  return snapshot.docs.map((doc) => doc['sender'] as String).toList();
}

Future<List<Map<String, String>>> fetchUserNamesAndPhotos(
  List<String> userIds,
) async {
  final users = <Map<String, String>>[];

  for (String id in userIds.take(2)) {
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(id).get();
    if (userDoc.exists) {
      users.add({
        'name': userDoc['fullNames'] ?? '',
        'photo': userDoc['profilePhoto'] ?? '',
      });
    }
  }

  return users;
}

Future<void> recordNewRecipeNotification({
  required String followerId,
  required String senderId,
  required String recipeId,
  required BuildContext context,
}) async {
  try {
    final senderDoc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(senderId)
            .get();
    final recipeDoc =
        await FirebaseFirestore.instance
            .collection('Recipe-App')
            .doc(recipeId)
            .get();

    if (!senderDoc.exists || !recipeDoc.exists) return;

    final fullName = senderDoc['fullNames'] ?? 'Someone';
    final recipeName = recipeDoc['name'] ?? 'a new recipe';
    final recipePhoto = recipeDoc['image'] ?? 'https://picsum.photos/300/200';
    debugPrint('recipe photo $recipePhoto');

    final fcmTokens = await _getAllFcmTokens(followerId);
    final notificationRef =
        FirebaseFirestore.instance
            .collection('Notifications')
            .doc(followerId)
            .collection('userNotifications')
            .doc();

    await notificationRef.set({
      'isRead': false,
      'sender': senderId,
      'time': FieldValue.serverTimestamp(),
      'type': 'new_recipe',
      'recipeId': recipeId,
      'notificationId': notificationRef.id,
    });

    for (final token in fcmTokens) {
      await _sendPushNotification(
        fcmToken: token,

        senderId: senderId,
        collapseKey: '',

        data: {
          'sender': senderId,
          'type': 'new_recipe',
          'productInfo': recipeId,
          'time': DateTime.now().toIso8601String(),
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'title': fullName,
          'body': 'a new recipe $recipeName',
          'imageurl': recipePhoto,
          'collapseKey': '',
        },
      );
    }
  } catch (e, stackTrace) {
    debugPrint('Recipe Notification Error: $e\n$stackTrace');
  }
}
