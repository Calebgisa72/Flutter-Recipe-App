class RecipeModel {
  final int cal;
  final RecipeCategory category;
  final String image;
  final List<Ingredients> ingredients;
  final String rating;
  final int reviews;
  final String time;

  RecipeModel({
    required this.cal,
    required this.category,
    required this.image,
    required this.ingredients,
    required this.rating,
    required this.time,
    this.reviews = 30,
  });
}

enum RecipeCategory { lunch, dinner, breakfast, vegetables }

class Ingredients {
  final String amount;
  final String image;
  final String name;

  Ingredients({required this.amount, required this.image, required this.name});
}
