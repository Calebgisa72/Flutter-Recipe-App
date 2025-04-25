import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/components/food_items_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const Profile({super.key, required this.documentSnapshot});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String selectedFollowState = 'follow';

  String selectedVar2 = 'receipes';
  DocumentSnapshot? _connectivityDoc;
  List<String> favoriteDocIds = ['dummy-id'];

  Future<void> _loadFavorites() async {
    final ids = await getFavoriteDocumentIds();
    setState(() => favoriteDocIds = ids.isNotEmpty ? ids : ['dummy-id']);
    print('Favorites loaded: $favoriteDocIds');
  }

  Query get allRecipes {
    final baseQuery = FirebaseFirestore.instance.collection('Recipe-App');

    if (selectedVar2 == 'receipes') {
      return baseQuery.where('userId', isEqualTo: userData['userId']);
    } else {
      return favoriteDocIds.isEmpty
          ? baseQuery.where('__name__', isEqualTo: 'non-existent-id')
          : baseQuery.where(FieldPath.documentId, whereIn: favoriteDocIds);
    }
  }

  Future<List<String>> getFavoriteDocumentIds() async {
    final userData = widget.documentSnapshot.data() as Map<String, dynamic>;
    final navuserId = userData['userId'];
    if (navuserId == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('UserFavorite')
            .where('favoriteBy', arrayContains: navuserId)
            .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  int get followersCount =>
      (_connectivityDoc?['Followedby'] as List?)?.length ?? 0;
  int get followingCount =>
      (_connectivityDoc?['Follows'] as List?)?.length ?? 0;

  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadFavorites();
    userData = widget.documentSnapshot.data() as Map<String, dynamic>;
  }

  String? loggedInUserId;

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUserId = prefs.getString('uid');
    });
  }

  Future<void> followUser() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getString('uid');
    if (loggedInUserId == null) return;

    final userData = widget.documentSnapshot.data() as Map<String, dynamic>;
    final targetUserId = userData['userId'];

    await FirebaseFirestore.instance
        .collection('Connectivity')
        .doc(targetUserId)
        .update({
          'Followedby': FieldValue.arrayUnion([loggedInUserId]),
        });
  }

  Future<void> unfollowUser() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getString('uid');
    if (loggedInUserId == null) return;

    final userData = widget.documentSnapshot.data() as Map<String, dynamic>;
    final targetUserId = userData['userId'];

    await FirebaseFirestore.instance
        .collection('Connectivity')
        .doc(targetUserId)
        .update({
          'Followedby': FieldValue.arrayRemove([loggedInUserId]),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
          color: bgColor,

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
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
                            snapshot.hasData && snapshot.data!.docs.isNotEmpty
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildCountTile('Recipes', recipesCount),
                                _buildCountTile(
                                  'Followers',
                                  (counts?['Followedby'] as List?)?.length ?? 0,
                                ),
                                _buildCountTile(
                                  'Following',
                                  (counts?['Follows'] as List?)?.length ?? 0,
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

                Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.08,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('Connectivity')
                                .doc(userData['userId'])
                                .snapshots(),
                        builder: (context, snapshot) {
                          final isFollowing =
                              snapshot.hasData
                                  ? (snapshot.data!['Followedby'] as List?)
                                          ?.contains(loggedInUserId) ??
                                      false
                                  : false;

                          return ElevatedButton(
                            onPressed: () async {
                              if (isFollowing) {
                                await unfollowUser();
                              } else {
                                await followUser();
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isFollowing
                                      ? const Color.fromARGB(255, 102, 114, 100)
                                      : primaryColor,
                              shadowColor: const Color.fromARGB(0, 174, 10, 10),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(bRadius),
                              ),
                              minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.37,
                                MediaQuery.of(context).size.height * 0.07,
                              ),
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
                      ),
                      SizedBox(width: 12),

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
                            borderRadius: BorderRadius.circular(bRadius),
                          ),
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.20,
                            MediaQuery.of(context).size.height * 0.07,
                          ),
                        ),
                        child: Icon(Icons.share, color: Colors.white, size: 26),
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.414,

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

                      return Container(
                        width: double.infinity,

                        child: GridView.builder(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 15,
                                childAspectRatio: 0.78,
                              ),
                          itemCount: recipes.length,
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
