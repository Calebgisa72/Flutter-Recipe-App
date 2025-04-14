import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/notifications/follow_receipe_notification.dart';
import 'package:flutter_recipe_app/notifications/multiuser.dart';
import 'package:collection/collection.dart';

class FollowNotificationCard extends StatefulWidget {
  final String time;
  final List<QueryDocumentSnapshot> notifications;
  final List<Map<String, dynamic>> modifiedData;

  const FollowNotificationCard({
    super.key,
    required this.time,
    required this.notifications,
    required this.modifiedData,
  });

  @override
  State<FollowNotificationCard> createState() => _FollowNotificationCardState();
}

class _FollowNotificationCardState extends State<FollowNotificationCard> {
  late Map<String, List<QueryDocumentSnapshot>> _likedGroups;
  late List<QueryDocumentSnapshot> _sortedNotifications;

  @override
  void initState() {
    super.initState();
    _sortedNotifications = [...widget.notifications]..sort(
      (a, b) => (b['time'] as Timestamp).compareTo(a['time'] as Timestamp),
    );

    _likedGroups = groupBy(
      widget.notifications.where((n) {
        final data = n.data() as Map<String, dynamic>?;
        return data != null &&
            data['type'] == 'liked' &&
            data.containsKey('recipeId');
      }),
      (n) => (n.data() as Map<String, dynamic>)['recipeId'] as String,
    ).map((recipeId, group) {
      final sortedGroup =
          group.toList()..sort(
            (a, b) =>
                (b['time'] as Timestamp).compareTo(a['time'] as Timestamp),
          );
      return MapEntry(recipeId, sortedGroup);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.93,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.05,
            alignment: Alignment.centerLeft,
            child: Text(
              widget.time,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ),
          ..._sortedNotifications
              .map((notification) {
                final type = notification['type'];
                final timestamp = notification['time'] as Timestamp;

                if (type == 'follow') {
                  return UserFollowRecipeCard(
                    notType: 'follow',
                    userInfo: notification['sender'],
                    time: timestamp,
                    productInfo: '',
                  );
                } else if (type == 'new_recipe') {
                  return UserFollowRecipeCard(
                    notType: 'new_recipe',
                    userInfo: notification['sender'],
                    time: timestamp,
                    productInfo: notification['recipeId'],
                  );
                } else if (type == 'liked') {
                  final group = _likedGroups[notification['recipeId']]!;
                  if (group.first['time'] == timestamp) {
                    return group.length > 1
                        ? MultiUserNotification(
                          usersIds: group.map((n) => n['sender']).toList(),
                          recipeId: notification['recipeId'],
                          time: timestamp,
                        )
                        : UserFollowRecipeCard(
                          notType: 'liked',
                          userInfo: notification['sender'],
                          time: timestamp,
                          productInfo: notification['recipeId'],
                        );
                  }
                  return const SizedBox.shrink();
                }
                return const SizedBox.shrink();
              })
              .where((widget) => widget is! SizedBox),
        ],
      ),
    );
  }
}
