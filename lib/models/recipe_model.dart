import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final int cal;
  final RecipeCategory category;
  final String image;
  final List<Ingredients> ingredients;
  final String rating;
  final int reviews;
  final int time;
  final String description;
  final String name;
  final String userId;

  RecipeModel({
    required this.name,
    required this.cal,
    required this.category,
    required this.image,
    required this.ingredients,
    required this.rating,
    required this.time,
    required this.description,
    required this.userId,
    this.reviews = 30,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'cal': cal,
    'category': category.name,
    'image': image,
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
    'rating': rating,
    'time': time,
    'reviews': reviews,
    'description': description,
    'userId': userId,
  };

  Future<void> createRecipe() async {
    await FirebaseFirestore.instance.collection('Recipe-App').add(toJson());
  }

  Future<void> updateRecipe(String docId) async {
    await FirebaseFirestore.instance
        .collection('Recipe-App')
        .doc(docId)
        .update(toJson());
  }
}

enum RecipeCategory { lunch, dinner, breakfast, vegetables }

class Ingredients {
  final String amount;
  final String image;
  final String name;

  Ingredients({required this.amount, required this.image, required this.name});

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'image': image,
    'name': name,
  };

  factory Ingredients.fromJson(Map<String, dynamic> json) {
    return Ingredients(
      amount: json['amount'],
      image: json['image'],
      name: json['name'],
    );
  }
}
