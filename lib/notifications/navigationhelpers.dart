import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/screens/profile.dart';
import 'package:flutter_recipe_app/screens/receipe_details.dart';

Future<void> navigateToRecipe(BuildContext context, String recipeInfo) async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection('Recipe-App')
          .doc(recipeInfo.trim())
          .get();

  if (snapshot.exists) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Details(documentSnapshot: snapshot),
      ),
    );
  }
}

Future<void> navigateToProfile(BuildContext context, String userInfo) async {
  final userId = userInfo.trim();

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Profile(userId: userId)),
  );
}
