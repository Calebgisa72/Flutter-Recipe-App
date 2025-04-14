import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/components/food_items_display.dart';
import 'package:flutter_recipe_app/components/my_icon_button.dart';
import 'package:flutter_recipe_app/providers/app_main_provider.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';

class ViewAllRecipes extends StatefulWidget {
  const ViewAllRecipes({super.key});

  @override
  State<ViewAllRecipes> createState() => _ViewAllRecipesState();
}

class _ViewAllRecipesState extends State<ViewAllRecipes> {
  String get currentUserId => AppMainProvider.of(context, listen: false).userId;

  Query get recipes => FirebaseFirestore.instance
      .collection('Recipe-App')
      .where('userId', isNotEqualTo: currentUserId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          SizedBox(width: 15),
          MyIconButton(
            icon: Icons.arrow_back_ios_new,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          Spacer(),
          Text(
            'Quick & Easy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          MyIconButton(icon: Iconsax.notification, pressed: () {}),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: recipes.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> recipeSnapshot) {
                if (recipeSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!recipeSnapshot.hasData ||
                    recipeSnapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No recipes found.'));
                }

                final List<DocumentSnapshot> recipesList =
                    recipeSnapshot.data!.docs;

                return GridView.builder(
                  itemCount: recipesList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final DocumentSnapshot recipe = recipesList[index];
                    return Column(
                      children: [
                        FoodItemsDisplay(documentSnapshot: recipe),
                        Transform.translate(
                          offset: Offset(-6, 0),
                          child: Row(
                            children: [
                              Icon(Iconsax.star1, color: Colors.amberAccent),
                              SizedBox(width: 5),
                              Text(
                                recipe['rating'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('/5'),
                              SizedBox(width: 5),
                              Text(
                                "${recipe['reviews']} reviews",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
