import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/notifications/notification_by_time.dart';
import 'package:flutter_recipe_app/screens/app_main_screen.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notifications> {
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        alignment: Alignment.topCenter,
        height: double.infinity,
        color: bgColor,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(height: 28, color: Colors.white),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white),
                height: MediaQuery.of(context).size.height * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: 27),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppMainScreen(),
                            ),
                          ),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 5),
                    IconButton(
                      icon: Icon(Iconsax.notification, size: 23),
                      onPressed: () => Navigator.pop(context),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: FutureBuilder<String>(
                    future: SharedPreferences.getInstance().then(
                      (prefs) => prefs.getString('uid') ?? '',
                    ),
                    builder: (context, uidSnapshot) {
                      if (!uidSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final String uid = uidSnapshot.data!;

                      return StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('Notifications')
                                .doc(uid)
                                .collection('userNotifications')
                                .orderBy('time', descending: true)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final notifications = snapshot.data!.docs;

                          final List<Map<String, dynamic>> notificationData =
                              notifications.map((doc) {
                                return <String, dynamic>{
                                  'doc': doc,
                                  'data': doc.data() as Map<String, dynamic>,
                                };
                              }).toList();

                          final likedGroups = groupBy(
                            notificationData.where(
                              (n) => n['data']['type'] == 'liked',
                            ),
                            (n) =>
                                n['data']['recipeId']?.toString() ??
                                'no_recipe',
                          );

                          List<Map<String, dynamic>> modifiedLiked = [];
                          likedGroups.forEach((recipeId, group) {
                            if (group.isEmpty) return;

                            group.sort(
                              (a, b) => (b['data']['time'] as Timestamp)
                                  .compareTo(a['data']['time'] as Timestamp),
                            );
                            final Timestamp latestTime =
                                group.first['data']['time'] as Timestamp;

                            modifiedLiked.addAll(
                              group.map<Map<String, dynamic>>((n) {
                                final originalData =
                                    n['data'] as Map<String, dynamic>;
                                return <String, dynamic>{
                                  'doc': n['doc'],
                                  'data': <String, dynamic>{
                                    ...originalData,
                                    'time': latestTime,
                                  },
                                };
                              }).toList(),
                            );
                          });

                          final nonLiked =
                              notificationData
                                  .where((n) => n['data']['type'] != 'liked')
                                  .toList();

                          final mergedNotifications = <Map<String, dynamic>>[
                            ...modifiedLiked,
                            ...nonLiked,
                          ]..sort(
                            (a, b) => (b['data']['time'] as Timestamp)
                                .compareTo(a['data']['time'] as Timestamp),
                          );

                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final yesterday = today.subtract(
                            const Duration(days: 1),
                          );

                          final groupedByTime = groupBy(mergedNotifications, (
                            entry,
                          ) {
                            final date =
                                (entry['data']['time'] as Timestamp).toDate();
                            if (now.difference(date).inMinutes < 2) {
                              return 'Now';
                            }

                            if (date.isAfter(today)) return 'Today';
                            if (date.isAfter(yesterday)) return 'Yesterday';
                            return DateFormat('d MMM').format(date);
                          });

                          return Column(
                            children:
                                groupedByTime.entries
                                    .map(
                                      (e) => FollowNotificationCard(
                                        time: e.key,
                                        notifications:
                                            e.value
                                                .map(
                                                  (entry) =>
                                                      entry['doc']
                                                          as QueryDocumentSnapshot<
                                                            Map<String, dynamic>
                                                          >,
                                                )
                                                .toList(),
                                        modifiedData:
                                            e.value
                                                .map(
                                                  (entry) =>
                                                      entry['data']
                                                          as Map<
                                                            String,
                                                            dynamic
                                                          >,
                                                )
                                                .toList(),
                                      ),
                                    )
                                    .toList(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
