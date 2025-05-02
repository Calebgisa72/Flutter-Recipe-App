import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/notifications/navigationhelpers.dart';

class MultiUserNotification extends StatefulWidget {
  final List<dynamic> usersIds;
  final String recipeId;
  final Timestamp time;

  const MultiUserNotification({
    super.key,
    required this.usersIds,
    required this.recipeId,
    required this.time,
  });

  @override
  State<MultiUserNotification> createState() => _MultiUserNotificationState();
}

class _MultiUserNotificationState extends State<MultiUserNotification> {
  @override
  Widget build(BuildContext context) {
    Future<String?> getRecipeImageUrl() async {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('Recipe-App')
                .doc(widget.recipeId.trim())
                .get();
        return doc.exists ? doc.get('image') : null;
      } catch (e) {
        return null;
      }
    }

    return GestureDetector(
      onTap: () {
        navigateToRecipe(context, widget.recipeId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        height: MediaQuery.of(context).size.height * 0.14,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(),
              width: MediaQuery.of(context).size.width * 0.20,
              height: MediaQuery.of(context).size.height * 0.14,
              child: FutureBuilder(
                future: Future.wait([
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(widget.usersIds[0].toString().trim())
                      .get(),
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(widget.usersIds[1].toString().trim())
                      .get(),
                ]),
                builder: (context, snapshot) {
                  final firstPhoto =
                      snapshot.hasData
                          ? snapshot.data![0]['profilePhoto']
                          : 'https://i.pravatar.cc/150?img=4';
                  final secondPhoto =
                      snapshot.hasData
                          ? snapshot.data![1]['profilePhoto']
                          : 'https://i.pravatar.cc/150?img=4';

                  return Stack(
                    children: [
                      Positioned(
                        right: 22,
                        top: 22,
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.height * 0.03,
                          backgroundImage: NetworkImage(firstPhoto),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        top: 50,
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.height * 0.03,
                          backgroundImage: NetworkImage(secondPhoto),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: Future.wait([
                      FirebaseFirestore.instance
                          .collection('Users')
                          .doc(widget.usersIds[0].toString().trim())
                          .get(),
                      FirebaseFirestore.instance
                          .collection('Users')
                          .doc(widget.usersIds[1].toString().trim())
                          .get(),
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();

                      final user1 = snapshot.data![0];
                      final user2 = snapshot.data![1];
                      final othersCount = widget.usersIds.length - 2;

                      return RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: user1['fullNames'] ?? 'User 1',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' ,'),
                            TextSpan(
                              text: user2['fullNames'] ?? 'User 2',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (othersCount > 0) TextSpan(text: 'and'),
                            TextSpan(text: '$othersCount'),
                            TextSpan(text: 'others'),
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          'liked your receipe',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.circle, size: 4),
                        SizedBox(width: 6),
                        StreamBuilder<DateTime>(
                          stream: Stream<DateTime>.periodic(
                            const Duration(minutes: 1),
                            (_) => DateTime.now(),
                          ),
                          builder: (context, _) {
                            final eventTime = widget.time.toDate();
                            final duration = DateTime.now().difference(
                              eventTime,
                            );
                            final timeText =
                                duration.inDays > 0
                                    ? '${duration.inDays}d${duration.inDays > 1 ? '' : ''}'
                                    : duration.inHours > 0
                                    ? '${duration.inHours}h${duration.inHours > 1 ? '' : ''}'
                                    : '${duration.inMinutes}m';

                            return Text(
                              timeText,
                              style: const TextStyle(fontSize: 14),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 37),
            FutureBuilder<String?>(
              future: getRecipeImageUrl(),
              builder: (context, snapshot) {
                final imageUrl = snapshot.data;

                return SizedBox(
                  height: 52,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image:
                            imageUrl != null
                                ? NetworkImage(imageUrl)
                                : AssetImage('') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
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
