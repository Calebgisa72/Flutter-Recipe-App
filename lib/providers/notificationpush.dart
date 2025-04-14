import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/notifications/follow_receipe_notification.dart';
import 'package:flutter_recipe_app/notifications/multiuser.dart';

class PushNotificationProvider with ChangeNotifier {
  List<DocumentSnapshot> _notifications = [];
  bool _isDialogShowing = false;

  List<DocumentSnapshot> get notifications => _notifications;

  Future<void> fetchUserNotifications(String userId) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Notifications')
              .doc(userId)
              .collection('userNotifications')
              .orderBy('time', descending: true)
              .get();

      _notifications = snapshot.docs;
      notifyListeners();
    } catch (e) {
      debugPrint('‼️ Error fetching notifications: $e');
    }
  }

  void showNotificationDialog({
    required BuildContext context,
    required Map<String, dynamic> notificationData,
  }) {
    debugPrint('\n📢 NEW NOTIFICATION RECEIVED');
    debugPrint('├─ Type: ${notificationData['type']}');
    debugPrint('├─ Context valid: ${context != null}');
    debugPrint('└─ Context mounted: ${context.mounted}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        debugPrint('⚠️ Context disposed - cannot show dialog');
        return;
      }

      final type = notificationData['type'] ?? '';
      if (type.isEmpty) {
        debugPrint('❌ Empty notification type');
        return;
      }

      _showPopupNotification(context, notificationData, type);
    });
  }

  Future<void> _showPopupNotification(
    BuildContext context,
    Map<String, dynamic> data,
    String type,
  ) async {
    if (_isDialogShowing) {
      debugPrint('⏸️ Dialog already visible - skipping duplicate');
      return;
    }

    debugPrint('\n🔄 ATTEMPTING TO SHOW DIALOG');
    _isDialogShowing = true;

    try {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              _isDialogShowing = false;
              return true;
            },
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: _buildNotificationWidget(data, type),
            ),
          );
        },
      );
      debugPrint('🗑️ Dialog closed');
    } catch (e) {
      debugPrint('‼️ Dialog error: $e');
    } finally {
      _isDialogShowing = false;
    }
  }

  Widget _buildNotificationWidget(Map<String, dynamic> data, String type) {
    debugPrint('🔨 Building widget for type: $type');

    try {
      if (type == 'follow') {
        return UserFollowRecipeCard(
          ismodal: true,
          notType: 'follow',
          userInfo: data['sender'],
          time: _parseTimestamp(data['time']),
          productInfo: '',
        );
      } else if (type == 'new_recipe') {
        return UserFollowRecipeCard(
          ismodal: true,
          notType: 'new_recipe',
          userInfo: data['sender'],
          time: _parseTimestamp(data['time']),
          productInfo: data['productInfo'] ?? '',
        );
      } else if (type == 'liked') {
        final userIds = (data['userIds'] as String).split(',');
        if (userIds.length == 1) {
          return UserFollowRecipeCard(
            ismodal: true,
            notType: 'liked',
            userInfo: data['sender'],
            time: _parseTimestamp(data['time']),
            productInfo: data['productInfo'] ?? '',
          );
        } else {
          return MultiUserNotification(
            ismodal: false,
            usersIds: userIds,
            recipeId: data['productInfo'],
            time: _parseTimestamp(data['time']),
          );
        }
      }
    } catch (e) {
      debugPrint('‼️ Widget build error: $e');
      return _buildErrorWidget();
    }

    return _buildErrorWidget();
  }

  Timestamp _parseTimestamp(dynamic time) {
    try {
      return time is String
          ? Timestamp.fromDate(DateTime.parse(time))
          : time as Timestamp;
    } catch (e) {
      debugPrint('⚠️ Error parsing timestamp: $e');
      return Timestamp.now();
    }
  }

  Widget _buildErrorWidget() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'Notification preview unavailable',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
