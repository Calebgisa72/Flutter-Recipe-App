
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/notifications/navigationhelpers.dart';
import 'package:flutter_recipe_app/providers/notification_providers.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserFollowRecipeCard extends StatefulWidget {
  final String notType;
  final String userInfo;
  final String productInfo;
  final Timestamp time;

  const UserFollowRecipeCard({
    super.key,
    required this.notType,
    required this.userInfo,
    required this.productInfo,
    required this.time,
  });

  @override
  State<UserFollowRecipeCard> createState() => _UserFollowRecipeCardState();
}

class _UserFollowRecipeCardState extends State<UserFollowRecipeCard> {
  Future<String?> _getRecipeImageUrl() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Recipe-App')
              .doc(widget.productInfo.trim())
              .get();
      return doc.exists ? doc.get('image') : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.userInfo.trim();
    if (kDebugMode) {
      print('event time ${widget.time}');
    }

    return GestureDetector(
      onTap: () {
        widget.notType == 'follow'
            ? navigateToProfile(context, widget.userInfo)
            : navigateToRecipe(context, widget.productInfo);
      },
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.09,
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FutureBuilder<String?>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userId)
                  .get()
                  .then(
                    (doc) =>
                        doc.exists ? doc.get('profilePhoto') as String? : null,
                  ),
              builder: (context, snapshot) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.12,
                  height: MediaQuery.of(context).size.height * 0.05,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    image: DecorationImage(
                      image:
                          snapshot.hasData && snapshot.data != null
                              ? NetworkImage(snapshot.data!)
                              : const AssetImage('assets/icons/profile.png')
                                  as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.43,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userId)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      }

                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Text(
                        userData['fullNames']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Text(
                        widget.notType == 'follow'
                            ? 'Now following'
                            : widget.notType == 'liked'
                            ? 'liked your recipe'
                            : 'New Recipe',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(Icons.circle, size: 4),
                      ),
                      StreamBuilder<DateTime>(
                        stream: Stream<DateTime>.periodic(
                          const Duration(minutes: 1),
                          (_) => DateTime.now(),
                        ),
                        builder: (context, _) {
                          final eventTime = widget.time.toDate();
                          final duration = DateTime.now().difference(eventTime);
                          final timeText =
                              duration.inDays > 0
                                  ? '${duration.inDays}d${duration.inDays > 1 ? 's' : ''}'
                                  : duration.inHours > 0
                                  ? '${duration.inHours}hr${duration.inHours > 1 ? 's' : ''}'
                                  : '${duration.inMinutes}min';

                          return Text(
                            timeText,
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            widget.notType == 'follow'
                ? FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder: (_, prefs) {
                    final uid = prefs.data?.getString('uid') ?? '';
                    return StreamBuilder(
                      stream:
                          FirebaseFirestore.instance
                              .collection('Connectivity')
                              .doc(uid)
                              .snapshots(),
                      builder: (_, snapshot) {
                        final isFollowing =
                            snapshot.data?['Follows']?.contains(userId) ??
                            false;
                        return isFollowing
                            ? SizedBox(
                              width: 80,
                              height: 50,
                              child: Center(
                                child: Text(
                                  'Following',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            )
                            : ElevatedButton(
                              onPressed: () {
                                final notificationProvider =
                                    Provider.of<NotificationProvider>(
                                      context,
                                      listen: false,
                                    );
                                notificationProvider.followUser(
                                  userId,
                                  context,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(90, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                      },
                    );
                  },
                )
                : FutureBuilder<String?>(
                  future: _getRecipeImageUrl(),
                  builder: (context, snapshot) {
                    final imageUrl = snapshot.data;
                    return Container(
                      width: 80,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image:
                              imageUrl != null
                                  ? NetworkImage(imageUrl)
                                  : AssetImage(''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
