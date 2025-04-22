import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/components/banner.dart';
import 'package:flutter_recipe_app/components/food_items_display.dart';
import 'package:flutter_recipe_app/components/my_icon_button.dart';
import 'package:flutter_recipe_app/providers/app_main_provider.dart';
import 'package:flutter_recipe_app/screens/view_all_recipes.dart';
import 'package:flutter_recipe_app/services/database_service.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String category = "All";
  final CollectionReference categories = FirebaseFirestore.instance.collection(
    'App-Category',
  );
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkDraft();
    });
  }

  Future<void> checkDraft() async {
    final d = await DatabaseService.instance.getDraft();
    if (mounted) {
      if (d != null) {
        _showDraftNotification();
      }
    }
  }

  void _showDraftNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📝 You have an unsaved recipe draft! Tap to continue editing.',
          style: TextStyle(fontSize: 16),
        ),
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Continue',
          textColor: Colors.amber,
          onPressed: () {
            AppMainProvider.of(context, listen: false).setSelectedTab(2);
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String get currentUserId => AppMainProvider.of(context, listen: false).userId;

  Query get filteredRecipes => FirebaseFirestore.instance
      .collection('Recipe-App')
      .where('category', isEqualTo: category)
      .where('userId', isNotEqualTo: currentUserId)
      .orderBy('userId')
      .orderBy('name');

  Query get allRecipes => FirebaseFirestore.instance
      .collection('Recipe-App')
      .where('userId', isNotEqualTo: currentUserId);

  Query get selectedRecipes => category == "All" ? allRecipes : filteredRecipes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header(),
                    searchBar(),
                    BannerToExplore(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    categoriesBuilder(),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quick & Easy",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewAllRecipes(),
                              ),
                            );
                          },
                          child: Text(
                            "View all",
                            style: TextStyle(
                              color: bannerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: selectedRecipes.snapshots(),
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

                  return Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: FoodItemsDisplay(
                              documentSnapshot: recipes[index],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> categoriesBuilder() {
    return StreamBuilder(
      stream: categories.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasError) {
          return Text('Error: ${streamSnapshot.error}');
        }

        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (streamSnapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: List.generate(streamSnapshot.data!.docs.length, (
                index,
              ) {
                final categoryName = streamSnapshot.data!.docs[index]["name"];
                final isSelected = category == categoryName;

                final categoryKey = GlobalKey();

                if (isSelected) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (categoryKey.currentContext != null) {
                      Scrollable.ensureVisible(
                        categoryKey.currentContext!,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: 0.5,
                      );
                    }
                  });
                }

                return GestureDetector(
                  key: categoryKey,
                  onTap: () {
                    setState(() {
                      category = categoryName;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: isSelected ? primaryColor : Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    margin: EdgeInsets.only(right: 20),
                    child: Text(
                      categoryName[0].toUpperCase() + categoryName.substring(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }

        return Center(child: Text('No data available'));
      },
    );
  }

  Padding searchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Iconsax.search_normal),
          border: InputBorder.none,
          hintText: "Search any recipes",
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Row header() {
    return Row(
      children: [
        Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        Spacer(),
        MyIconButton(icon: Iconsax.notification, pressed: () {}),
      ],
    );
  }
}
