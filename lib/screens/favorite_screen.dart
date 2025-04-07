import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/components/food_items_display.dart';
import 'package:flutter_recipe_app/providers/favorite_provider.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = FavoriteProvider.of(context);
    final favoriteItems = favProvider.favoriteIds;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body:
          favoriteItems.isEmpty
              ? Center(
                child: Text(
                  'No Favorites yet!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: favoriteItems.length,
                itemBuilder: (context, index) {
                  String favoriteId = favoriteItems[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection("Recipe-App")
                            .doc(favoriteId)
                            .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(child: Text('Error Loading Favorites'));
                      }
                      var favoriteItem = snapshot.data!;
                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 10,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          favoriteItem['image'],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        favoriteItem['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Iconsax.flash1,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            "${favoriteItem['cal']} Cal",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            " . ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Icon(
                                            Iconsax.clock,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            favoriteItem['time'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 50,
                            right: 15,
                            child: GestureDetector(
                              onTap: () {
                                favProvider.toggleFavorite(favoriteItem);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.delete, color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
    );
  }
}
