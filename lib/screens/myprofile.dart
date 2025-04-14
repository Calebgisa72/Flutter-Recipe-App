import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/components/food_items_display.dart';
import 'package:flutter_recipe_app/notifications/notificationcount.dart';
import 'package:flutter_recipe_app/notifications/recordnotification.dart';
import 'package:flutter_recipe_app/profilefunctions/profilecountscard.dart';
import 'package:flutter_recipe_app/providers/favorite_provider.dart';

import 'package:flutter_recipe_app/screens/login.dart';
import 'package:flutter_recipe_app/screens/recipe_upload_flow.dart';
import 'package:flutter_recipe_app/utils/constants.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  final String userId;

  const MyProfile({super.key, required this.userId});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String selectedFollowState = 'follow';
  Map<String, dynamic> userData = {
    'profilePhoto': '',
    'fullNames': '',
    'userId': '',
  };

  @override
  void initState() {
    super.initState();
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

  bool isLoggingOut = false;

  void handleLogout() async {
    setState(() => isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      final deviceId = prefs.getString('deviceId');

      if (uid != null && deviceId != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .collection('devices')
            .doc(deviceId)
            .delete();
      }

      await FirebaseAuth.instance.signOut();
      await prefs.remove('uid');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => isLoggingOut = false);
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
          decoration: BoxDecoration(color: bgColor),
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: double.infinity,
                        child: NotificationIconWithBadge(),
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
                            if (recipeSnapshot.connectionState ==
                                ConnectionState.waiting) {}
                            if (recipeSnapshot.hasError) {
                              print(
                                'Error fetching recipes: ${recipeSnapshot.error}',
                              );
                            }
                            if (recipeSnapshot.hasData) {
                              print(
                                'Found ${recipeSnapshot.data!.docs.length} recipes',
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
                SizedBox(height: 15),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.08,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await recordFollowNotification(
                            targetUserId: widget.userId,
                            senderId: '4bkOqq3I3Ka4PunDgzrdkArJ8On2',

                            context: context,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            81,
                            78,
                            108,
                          ),
                          shadowColor: const Color.fromARGB(0, 174, 10, 10),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(80, 50),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () {
                          handleLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shadowColor: const Color.fromARGB(0, 174, 10, 10),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(80, 50),
                        ),
                        child:
                            isLoggingOut
                                ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,

                                    strokeWidth: 4,
                                    strokeCap: StrokeCap.round,
                                  ),
                                )
                                : Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 25,
                                ),
                      ),
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
                  height: MediaQuery.of(context).size.height * 0.36,
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
                                mainAxisSpacing: 15,
                              ),
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FoodItemsDisplay(
                                  documentSnapshot: recipes[index],
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.04,
                                  alignment: Alignment.centerRight,
                                  child:
                                      selectedVar2 == 'receipes'
                                          ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 15,
                                                ),
                                                child: Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        bool
                                                        confirmDelete = await showDialog(
                                                          context: context,
                                                          builder:
                                                              (
                                                                context,
                                                              ) => AlertDialog(
                                                                title: Text(
                                                                  'Delete Recipe',
                                                                ),
                                                                content: Text(
                                                                  'Are you sure you want to delete this recipe?',
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.pop(
                                                                          context,
                                                                          false,
                                                                        ),
                                                                    child: Text(
                                                                      'Cancel',
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.pop(
                                                                          context,
                                                                          true,
                                                                        ),
                                                                    child: Text(
                                                                      'Delete',
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.red,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                        );

                                                        if (confirmDelete ==
                                                            true) {
                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                  'Recipe-App',
                                                                )
                                                                .doc(
                                                                  recipes[index]
                                                                      .id,
                                                                )
                                                                .delete();

                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Recipe deleted successfully',
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            );
                                                          } catch (e) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Failed to delete recipe: ${e.toString()}',
                                                                ),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      splashColor: Colors.red
                                                          .withOpacity(0.2),
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 25,
                                                      ),
                                                    ),

                                                    SizedBox(width: 15),

                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => RecipeFormFlow(
                                                                  edit: true,
                                                                  documentSnapshot:
                                                                      recipes[index],
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                      splashColor: Colors.red
                                                          .withOpacity(0.2),
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Colors.black,
                                                        size: 25,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                          : Container(),
                                ),
                              ],
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
