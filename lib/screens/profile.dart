import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/components/food_items_display.dart';
import 'package:flutter_recipe_app/profilefunctions/profilecountscard.dart';
import 'package:flutter_recipe_app/providers/favorite_provider.dart';
import 'package:flutter_recipe_app/providers/notification_providers.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final String userId;

  const Profile({super.key, required this.userId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String selectedFollowState = 'follow';
  Map<String, dynamic> userData = {
    'profilePhoto': '',
    'fullNames': '',
    'userId': '',
  };

  @override
  void initState() {
    super.initState();
    print('Fetching profile for user: ${widget.userId}');
    _loadUserData();
  }

  bool isFollowing = false;
  String selectedVar2 = 'receipes';

  Stream<List<DocumentSnapshot>> get allRecipes {
    final favProvider = FavoriteProvider.of(context);
    final favoriteItems = favProvider.favoriteIds;
    if (selectedVar2 == 'receipes') {
      return FirebaseFirestore.instance
          .collection('Recipe-App')
          .where('userId', isEqualTo: widget.userId)
          .snapshots()
          .map((snap) => snap.docs);
    } else {
      return FirebaseFirestore.instance
          .collection('Recipe-App')
          .where(FieldPath.documentId, whereIn: favoriteItems)
          .snapshots()
          .map((snap) => snap.docs);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.userId)
              .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data()!;
          userData['userId'] = widget.userId;
        });
      } else {}
    } catch (e) {
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,

          child: Container(
            margin: EdgeInsets.only(top: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.065,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.all(3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.chevron_left, size: 28),
                        ),
                      ),
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: double.infinity,
                        child: Center(
                          child: IconButton(
                            onPressed: () => {},
                            icon: Icon(Iconsax.notification, size: 25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(userData['profilePhoto']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userData['fullNames'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('Connectivity')
                              .where(
                                FieldPath.documentId,
                                isEqualTo: widget.userId,
                              )
                              .snapshots(),
                      builder: (context, snapshot) {
                        final counts =
                            snapshot.hasData && snapshot.data!.docs.isNotEmpty
                                ? snapshot.data!.docs.first.data()
                                    as Map<String, dynamic>
                                : null;

                        return StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('Recipe-App')
                                  .where('userId', isEqualTo: widget.userId)
                                  .snapshots(),
                          builder: (context, recipeSnapshot) {
                            if (recipeSnapshot.hasError) {
                              print(
                                'Error fetching recipes: ${recipeSnapshot.error}',
                              );
                            }

                            final recipesCount =
                                recipeSnapshot.hasData
                                    ? recipeSnapshot.data!.docs.length
                                    : 0;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CountTile(
                                  label: 'Recipes',
                                  count: recipesCount,
                                ),
                                CountTile(
                                  label: 'Followers',
                                  count:
                                      (counts?['Followedby'] as List?)
                                          ?.length ??
                                      0,
                                ),
                                CountTile(
                                  label: 'Following',
                                  count:
                                      (counts?['Follows'] as List?)?.length ??
                                      0,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.08,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FutureBuilder(
                        future: SharedPreferences.getInstance(),
                        builder: (context, prefsSnapshot) {
                          final currentuserId = prefsSnapshot.data?.getString(
                            'uid',
                          );
                          return StreamBuilder(
                            stream:
                                currentuserId != null
                                    ? FirebaseFirestore.instance
                                        .collection('Connectivity')
                                        .doc(widget.userId)
                                        .snapshots()
                                    : Stream.empty(),
                            builder: (context, snapshot) {
                              final isFollowing =
                                  (snapshot.data?['Followedby'] as List?)
                                      ?.contains(currentuserId) ??
                                  false;

                              return ElevatedButton(
                                onPressed: () async {
                                  if (isFollowing) {
                                    final notificationProvider =
                                        Provider.of<NotificationProvider>(
                                          context,
                                          listen: false,
                                        );
                                    notificationProvider.unfollowUser(
                                      widget.userId,
                                    );
                                  } else {
                                    final notificationProvider =
                                        Provider.of<NotificationProvider>(
                                          context,
                                          listen: false,
                                        );
                                    notificationProvider.followUser(
                                      widget.userId,
                                      context,
                                    );
                                  }
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isFollowing
                                          ? const Color.fromARGB(
                                            255,
                                            102,
                                            114,
                                            100,
                                          )
                                          : primaryColor,
                                  shadowColor: const Color.fromARGB(
                                    0,
                                    174,
                                    10,
                                    10,
                                  ),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      bRadius,
                                    ),
                                  ),
                                  minimumSize: Size(150, 50),
                                ),
                                child: Text(
                                  isFollowing ? 'Unfollow' : 'Follow',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(width: 12),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 8),

                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.width * 0.1,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border:
                              selectedVar2 == 'receipes'
                                  ? Border(
                                    bottom: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        3,
                                        248,
                                        8,
                                      ),
                                      width: 2,
                                    ),
                                  )
                                  : null, //
                        ),
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.width * 0.1,
                        child: ElevatedButton(
                          onPressed:
                              () => setState(() => selectedVar2 = 'receipes'),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            surfaceTintColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                          ),
                          child: (Text(
                            'Receipes',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight:
                                  selectedVar2 == 'receipes'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          )),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border:
                              selectedVar2 == 'liked'
                                  ? Border(
                                    bottom: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        93,
                                        243,
                                        33,
                                      ),
                                      width: 3,
                                    ),
                                  )
                                  : null,
                        ),
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.width * 0.1,
                        child: ElevatedButton(
                          onPressed:
                              () => setState(() => selectedVar2 = 'liked'),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Liked',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight:
                                  selectedVar2 == 'liked'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.41,

                  child: StreamBuilder<List<DocumentSnapshot>>(
                    stream: allRecipes,
                    builder: (
                      context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot,
                    ) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final recipes = snapshot.data ?? [];
                      if (recipes.isEmpty) {
                        return Center(child: Text('No recipes found.'));
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: GridView.builder(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          itemCount: recipes.length,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) {
                            return FoodItemsDisplay(
                              documentSnapshot: recipes[index],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
