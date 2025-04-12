import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/components/food_items_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/screens/home_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String selectedVar = 'follow';
  String selectedVar2 = 'receipes';

  Query get allRecipes => FirebaseFirestore.instance.collection('Recipe-App');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 30),
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 0.96,

          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,

                  height: MediaQuery.of(context).size.height * 0.05,

                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.all(3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: 33,
                          color: Colors.black, // Customize icon color
                        ),
                      ),

                      // Share Button (ElevatedButton)
                      ElevatedButton(
                        onPressed: () {
                          // Add your share functionality here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Icon(Icons.share, size: 28, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadiusDirectional.circular(130),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.17,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(130),
                        border: Border.all(
                          color: const Color.fromARGB(255, 16, 15, 15),
                          width: 1,
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/icons/profile.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.05,

                  child: Center(
                    child: Text(
                      'Kido  Martin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.09,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 1,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '32',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              'Receipes',
                              style: TextStyle(
                                fontSize: 19,
                                color: const Color.fromARGB(255, 150, 152, 152),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 1,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '707',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              'Following',
                              style: TextStyle(
                                fontSize: 19,
                                color: const Color.fromARGB(255, 150, 152, 152),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 1,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '1,200',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              'Followers',
                              style: TextStyle(
                                fontSize: 19,
                                color: const Color.fromARGB(255, 150, 152, 152),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedVar =
                            (selectedVar == 'follow') ? 'Unfollow' : 'follow';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedVar == 'follow'
                              ? const Color.fromARGB(255, 39, 239, 4)
                              : const Color.fromARGB(255, 102, 114, 100),

                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black54,
                    ),
                    child: Text(
                      selectedVar == 'follow' ? 'Follow' : 'Unfollow',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width * 0.9,
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
                            surfaceTintColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                          ),
                          child: (Text(
                            'Receipes',
                            style: TextStyle(
                              fontSize: 20,
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
                            surfaceTintColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                          ),
                          child: (Text(
                            'Liked',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight:
                                  selectedVar == 'liked'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 17),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.27,

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
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 15,
                              ),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 250,
                                minHeight: 200,
                              ),
                              child: FoodItemsDisplay(
                                documentSnapshot: recipes[index],
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
}
