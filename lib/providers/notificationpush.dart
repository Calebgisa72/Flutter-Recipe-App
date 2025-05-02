import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/notifications/follow_receipe_notification.dart';

class PushNotificationProvider with ChangeNotifier {
  List<DocumentSnapshot> _notifications = [];

  List<DocumentSnapshot> get notifications => _notifications;

  Future<void> fetchUserNotifications(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('Notifications')
            .doc(userId)
            .collection('userNotifications')
            .orderBy('time', descending: true)
            .get();

    _notifications = snapshot.docs;
    notifyListeners();
  }

  void showNotificationDialog({
    required BuildContext context,
    required Map<String, dynamic> notificationData,
  }) {
    final type = notificationData['type'] ?? '';
    _showPopupNotification(context, notificationData, type);
  }

  void handleIncomingNotification({
    required DocumentSnapshot notification,
    required BuildContext context,
  }) {
    _notifications.insert(0, notification);
    notifyListeners();

    final data = notification.data() as Map<String, dynamic>;
    final type = data['type'];

    if (type == 'follow' || type == 'new_recipe') {
      _showPopupNotification(context, data, type);
    }
  }

  void _showPopupNotification(
    BuildContext context,
    Map<String, dynamic> data,
    String type,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),
            child: _buildNotificationWidget(data, type),
          ),
    );

    Future.delayed(Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  Widget _buildNotificationWidget(Map<String, dynamic> data, String type) {
    return type == 'follow'
        ? UserFollowRecipeCard(
          notType: 'follow',
          userInfo: data['sender'],
          time:
              data['time'] is String
                  ? Timestamp.fromDate(DateTime.parse(data['time']))
                  : data['time'] as Timestamp,
          productInfo: '',
        )
        : UserFollowRecipeCard(
          notType: 'new_recipe',
          userInfo: data['sender'],
          time:
              data['time'] is String
                  ? Timestamp.fromDate(DateTime.parse(data['time']))
                  : data['time'] as Timestamp,
          productInfo: data['recipeId'] ?? '',
        );
  }
}
