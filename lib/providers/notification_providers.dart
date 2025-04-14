import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/notifications/recordnotification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> followUser(String targetUserId, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('uid');

      if (currentUserId == null) return;

      await _firestore.collection('Connectivity').doc(targetUserId).update({
        'Followedby': FieldValue.arrayUnion([currentUserId]),
      });

      await recordFollowNotification(
        targetUserId: targetUserId,
        senderId: currentUserId,
        context: context,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error following user: $e');
      rethrow;
    }
  }

  Future<void> unfollowUser(String targetUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('uid');

      if (currentUserId == null) return;

      await _firestore.collection('Connectivity').doc(targetUserId).update({
        'Followedby': FieldValue.arrayRemove([currentUserId]),
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error unfollowing user: $e');
      rethrow;
    }
  }
}
