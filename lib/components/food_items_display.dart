import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/providers/favorite_provider.dart';
import 'package:flutter_recipe_app/screens/Receiptdetails.dart';
import 'package:iconsax/iconsax.dart';

class FoodItemsDisplay extends StatelessWidget {
  final DocumentSnapshot<Object?> documentSnapshot;

  const FoodItemsDisplay({super.key, required this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    final favProvider = FavoriteProvider.of(context);

    return SizedBox(
      width: 200,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Details(documentSnapshot: documentSnapshot),
            ),
          );
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(documentSnapshot['image']),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  documentSnapshot['name'],
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Iconsax.flash1, size: 16, color: Colors.grey),
                    Text(
                      "${documentSnapshot['cal']} Cal",
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
                    Icon(Iconsax.clock, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      documentSnapshot['time'],
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
            Positioned(
              top: 5,
              right: 5,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: InkWell(
                  onTap: () {
                    favProvider.toggleFavorite(documentSnapshot);
                  },
                  child:
                      favProvider.isLoading(documentSnapshot.id)
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : favProvider.alreadyFav(documentSnapshot)
                          ? Icon(Iconsax.heart5, color: Colors.red, size: 24)
                          : Icon(Iconsax.heart, color: Colors.black, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
