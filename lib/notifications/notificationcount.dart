import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/providers/notification_providers.dart';
import 'package:flutter_recipe_app/screens/notifications.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationIconWithBadge extends StatelessWidget {
  const NotificationIconWithBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('uid'),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        String uid = snapshot.data!;
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('Notifications')
                  .doc(uid)
                  .collection('userNotifications')
                  .where('isRead', isEqualTo: false)
                  .snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _NotificationBadge(count: count);
          },
        );
      },
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Iconsax.notification),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Notifications()),
            );
            Provider.of<NotificationProvider>(
              context,
              listen: false,
            ).markAllNotificationsAsRead();
          },
        ),
        if (count > 0)
          Positioned(
            right: 2,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 98, 190, 223),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 23, minHeight: 23),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
