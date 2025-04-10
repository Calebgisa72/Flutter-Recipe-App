import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/components/my_icon_button.dart';
import 'package:flutter_recipe_app/providers/favorite_provider.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';

class Details extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const Details({super.key, required this.documentSnapshot});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    final favProvider = FavoriteProvider.of(context);
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          recipeImage(context),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  color: Colors.white,
                  border: Border.all(
                    width: 1,
                    color: const Color.fromARGB(255, 194, 191, 191),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        height: 6,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 195, 192, 192),
                          border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(255, 219, 218, 218),
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.documentSnapshot['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.documentSnapshot["category"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Iconsax.flash1,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                Text(
                                  "${widget.documentSnapshot['cal']} Cal",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Text(
                                  " . ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Icon(
                                  Iconsax.clock,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.documentSnapshot['time'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        bRadius,
                                      ),
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    child: Image.asset(
                                      'assets/icons/profile.png',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Elen Shebah',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      favProvider.toggleFavorite(
                                        widget.documentSnapshot,
                                      );
                                    },
                                    icon:
                                        favProvider.isLoading(
                                              widget.documentSnapshot.id,
                                            )
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : favProvider.alreadyFav(
                                              widget.documentSnapshot,
                                            )
                                            ? const Icon(
                                              Iconsax.heart5,
                                              color: Colors.red,
                                              size: 24,
                                            )
                                            : const Icon(
                                              Iconsax.heart,
                                              color: Colors.black,
                                              size: 24,
                                            ),
                                  ),
                                  const Text(
                                    '773 Favs',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        height: 20,
                      ),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'Your recipe has been uploaded, you can see it on your profile. Your recipe has been uploaded, you can see it on your profile.',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 138, 137, 137),
                          fontSize: 17,
                        ),
                      ),

                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        height: 20,
                      ),

                      // Ingredients section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ingredients',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIngredientItem('4 Eggs'),
                          _buildIngredientItem('1/2 Butter'),
                          _buildIngredientItem('1/2 Butter'),
                        ],
                      ),

                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        height: 20,
                      ),

                      // Steps section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Steps',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      _buildStepItem(
                        stepNumber: 1,
                        description:
                            'Your recipe has been uploaded successfully, Your recipe has been uploaded successfully',
                        imagePath: 'assets/images/ingredients.png',
                      ),
                      _buildStepItem(
                        stepNumber: 2,
                        description:
                            'Your recipe has been uploaded successfully, Your recipe has been uploaded successfully',
                        imagePath: 'assets/images/ingredients.png',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String description,
    required String imagePath,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 92, 101, 121),
            borderRadius: BorderRadius.circular(bRadius),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget recipeImage(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.documentSnapshot['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  MyIconButton(
                    icon: Icons.arrow_back,
                    pressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Spacer(),
                  MyIconButton(icon: Iconsax.notification, pressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
