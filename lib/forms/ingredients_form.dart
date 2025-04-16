import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/models/recipe_model.dart';
import 'package:flutter_recipe_app/screens/recipe_upload_flow.dart';
import 'package:flutter_recipe_app/utils/constants.dart';

class IngredientsForm extends StatefulWidget {
  final RecipeFormData formData;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;
  const IngredientsForm({
    super.key,
    required this.formData,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<IngredientsForm> createState() => _IngredientsFormState();
}

class _IngredientsFormState extends State<IngredientsForm> {
  late List<Map<String, TextEditingController>> ingredientControllers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    ingredientControllers =
        widget.formData.ingredients.map((ingredient) {
          return {
            'name': TextEditingController(text: ingredient.name),
            'amount': TextEditingController(text: ingredient.amount),
            'image': TextEditingController(text: ingredient.image),
          };
        }).toList();

    if (ingredientControllers.isEmpty) {
      addIngredientField();
    }
  }

  void addIngredientField() {
    setState(() {
      ingredientControllers.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
        'image': TextEditingController(),
      });
    });
  }

  void removeIngredientField(int index) {
    setState(() {
      ingredientControllers.removeAt(index);
    });
  }

  void _saveAndSubmit() async {
    for (var controller in ingredientControllers) {
      if (controller['name']!.text.isEmpty ||
          controller['amount']!.text.isEmpty ||
          controller['image']!.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all ingredient fields')),
        );
        return;
      }
    }

    widget.formData.ingredients =
        ingredientControllers
            .map(
              (c) => Ingredients(
                name: c['name']!.text,
                amount: c['amount']!.text,
                image: c['image']!.text,
              ),
            )
            .toList();

    setState(() => _isSubmitting = true);

    await widget.onSubmit();

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...ingredientControllers.map((c) {
                  final index = ingredientControllers.indexOf(c);
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Ingredient ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          if (ingredientControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeIngredientField(index),
                            ),
                        ],
                      ),
                      TextFormField(
                        controller: c['name'],
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextFormField(
                        controller: c['amount'],
                        decoration: const InputDecoration(labelText: 'Amount'),
                      ),
                      TextFormField(
                        controller: c['image'],
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                        ),
                      ),
                      const Divider(height: 32),
                    ],
                  );
                }).toList(),
                ElevatedButton.icon(
                  onPressed: addIngredientField,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add Ingredient',
                    style: TextStyle(fontSize: 15, color: foreGround),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    iconSize: 30,
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(bRadius),
                    ),
                  ),
                  child: const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Back',
                        style: TextStyle(fontSize: 16, color: foreGround),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? () {} : _saveAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitting ? Colors.grey : primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(bRadius),
                    ),
                  ),
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryColor,
                                ),
                              )
                              : Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
