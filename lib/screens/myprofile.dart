import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/components/food_items_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/screens/login.dart';

import 'package:flutter_recipe_app/screens/recipe_upload_flow.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String selectedFollowState = 'follow';

  String? currentUserId;

  List<Map<String, dynamic>> userdata = [];

  String selectedVar2 = 'receipes';
  DocumentSnapshot? _connectivityDoc;
  List<String> favoriteDocIds = ['dummy-id'];

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('uid');
    });
  }

  bool isLoggingOut = false;
  String? logoutErrorMessage;

  void handleLogout() async {
    setState(() {
      isLoggingOut = true;
      logoutErrorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('uid');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        logoutErrorMessage = 'Logout failed: ${e.message}';
      });
      print('Firebase logout error: $e');
    } catch (e) {
      setState(() {
        logoutErrorMessage = 'An unexpected error occurred';
      });
      print('Logout error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    final ids = await getFavoriteDocumentIds();
    setState(() => favoriteDocIds = ids.isNotEmpty ? ids : ['dummy-id']);
  }

  Query get allRecipes {
    final baseQuery = FirebaseFirestore.instance.collection('Recipe-App');

    if (selectedVar2 == 'receipes') {
      return baseQuery.where('userId', isEqualTo: currentUserId);
    } else {
      return favoriteDocIds.isEmpty
          ? baseQuery.where('__name__', isEqualTo: 'non-existent-id')
          : baseQuery.where(FieldPath.documentId, whereIn: favoriteDocIds);
    }
  }

  Future<List<String>> getFavoriteDocumentIds() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('UserFavorite')
            .where('favoriteBy', arrayContains: currentUserId)
            .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  int get followersCount =>
      (_connectivityDoc?['Followedby'] as List?)?.length ?? 0;
  int get followingCount =>
      (_connectivityDoc?['Follows'] as List?)?.length ?? 0;

  @override
  void initState() {
    super.initState();

    _loadFavorites();
    _loadUserData();
  }

  Future<void> followUser() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getString('uid');
    if (loggedInUserId == null) return;

    final targetUserId = currentUserId;

    await FirebaseFirestore.instance
        .collection('Connectivity')
        .doc(targetUserId)
        .update({
          'Followedby': FieldValue.arrayUnion([loggedInUserId]),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 0.97,
          color: bgColor,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                SizedBox(height: 30),
                Container(
                  width: MediaQuery.of(context).size.width * 0.94,

                  height: MediaQuery.of(context).size.height * 0.065,

                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.all(3),
                  child: Container(
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
                ),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('Users')
                          .where('userId', isEqualTo: currentUserId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text('No user found');
                    }

                    final userData =
                        snapshot.data!.docs.first.data()
                            as Map<String, dynamic>;

                    return Container(
                      width: MediaQuery.of(context).size.width * 0.94,
                      height: MediaQuery.of(context).size.height * 0.32,
                      decoration: BoxDecoration(),

                      child: Column(
                        children: [
                          Container(
                            width: 130,
                            height: 130,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              image: DecorationImage(
                                image: NetworkImage(
                                  userData['profilePhoto'] as String,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            userData['fullNames'] as String,
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
                                      isEqualTo: userData['userId'],
                                    )
                                    .snapshots(),
                            builder: (context, snapshot) {
                              final counts =
                                  snapshot.hasData &&
                                          snapshot.data!.docs.isNotEmpty
                                      ? snapshot.data!.docs.first.data()
                                          as Map<String, dynamic>
                                      : null;

                              return StreamBuilder<QuerySnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection('Recipe-App')
                                        .where(
                                          'userId',
                                          isEqualTo: userData['userId'],
                                        )
                                        .snapshots(),
                                builder: (context, recipeSnapshot) {
                                  final recipesCount =
                                      recipeSnapshot.hasData
                                          ? recipeSnapshot.data!.docs.length
                                          : 0;

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildCountTile('Recipes', recipesCount),
                                      _buildCountTile(
                                        'Followers',
                                        (counts?['Followedby'] as List?)
                                                ?.length ??
                                            0,
                                      ),
                                      _buildCountTile(
                                        'Following',
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
                    );
                  },
                ),

                Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.08,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
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
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.37,
                            MediaQuery.of(context).size.height * 0.07,
                          ),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      SizedBox(width: 12),
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
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.37,
                            MediaQuery.of(context).size.height * 0.07,
                          ),
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
                  margin: EdgeInsets.only(top: 4),
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.33,
                  decoration: BoxDecoration(),

                  child: StreamBuilder<QuerySnapshot>(
                    stream: allRecipes.snapshots(),
                    builder: (
                      context,
                      AsyncSnapshot<QuerySnapshot> recipeSnapshot,
                    ) {
                      if (recipeSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${recipeSnapshot.error}'),
                        );
                      }

                      if (recipeSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!recipeSnapshot.hasData ||
                          recipeSnapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No recipes found.'));
                      }

                      final List<DocumentSnapshot> recipes =
                          recipeSnapshot.data!.docs;

                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,

                        width: double.infinity,

                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 15,
                                childAspectRatio:
                                    selectedVar2 == 'receipes' ? 0.63 : 0.68,
                              ),
                          itemCount: recipes.length,
                          padding: EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FoodItemsDisplay(
                                    documentSnapshot: recipes[index],
                                  ),
                                  Container(
                                    width: 70,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.04,
                                    decoration: BoxDecoration(),
                                    child:
                                        selectedVar2 == 'receipes'
                                            ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                InkWell(
                                                  onTap: () {},
                                                  splashColor: Colors.red
                                                      .withOpacity(0.2),
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size: 25,
                                                  ),
                                                ),

                                                InkWell(
                                                  onTap: () {
                                                    print(
                                                      'button tapped on edit',
                                                    );
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
                                            )
                                            : Container(),
                                  ),
                                ],
                              ),
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

  Widget _buildCountTile(String label, int count) => SizedBox(
    width: MediaQuery.of(context).size.width * 0.17,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black)),
      ],
    ),
  );
}
