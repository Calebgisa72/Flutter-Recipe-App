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

      await _firestore.collection('Connectivity').doc(currentUserId).update({
        'Follows': FieldValue.arrayUnion([targetUserId]),
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

      await _firestore.collection('Connectivity').doc(currentUserId).update({
        'Follows': FieldValue.arrayRemove([targetUserId]),
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error unfollowing user: $e');
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) return;

      final notifRef = _firestore
          .collection('Notifications')
          .doc(uid)
          .collection('userNotifications');

      final unread = await notifRef.where('isRead', isEqualTo: false).get();
      final batch = _firestore.batch();

      for (var doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
      rethrow;
    }
  }
}
