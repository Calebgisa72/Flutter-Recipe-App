import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/models/recipe_model.dart';
import 'package:flutter_recipe_app/screens/recipe_upload_flow.dart';
import 'package:flutter_recipe_app/utils/constants.dart';

class BasicInfoForm extends StatefulWidget {
  final RecipeFormData formData;
  final VoidCallback onNext;
  final bool edit;
  const BasicInfoForm({
    super.key,
    required this.formData,
    required this.onNext,
    required this.edit,
  });

  @override
  State<BasicInfoForm> createState() => _BasicInfoFormState();
}

class _BasicInfoFormState extends State<BasicInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController calController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  RecipeCategory selectedCategory = RecipeCategory.lunch;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.formData.name;
    calController.text = widget.formData.cal.toString();
    timeController.text = widget.formData.time.toString();
    ratingController.text = widget.formData.rating;
    descriptionController.text = widget.formData.description;
    selectedCategory = widget.formData.category;
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate()) {
      final wordCount =
          descriptionController.text
              .split(RegExp(r'\s+'))
              .where((word) => word.isNotEmpty)
              .length;
      if (wordCount < 30 || wordCount > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Description must be between 30 and 100 words'),
          ),
        );
        return;
      }

      widget.formData.name = nameController.text;
      widget.formData.cal = int.parse(calController.text);
      widget.formData.time = int.parse(timeController.text);
      widget.formData.rating = ratingController.text;
      widget.formData.description = descriptionController.text;
      widget.formData.category = selectedCategory;

      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name',
                labelStyle: TextStyle(fontSize: 18),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: calController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (In Minutes)'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: ratingController,
              decoration: const InputDecoration(labelText: 'Rating (1-5)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Rating is required';
                }
                final rating = double.tryParse(value);
                if (rating == null) {
                  return 'Please enter a valid number';
                }
                if (rating < 1 || rating > 5) {
                  return 'Rating must be between 1 and 5';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (30-100 words)',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Required';
                }
                final wordCount =
                    v
                        .split(RegExp(r'\s+'))
                        .where((word) => word.isNotEmpty)
                        .length;
                if (wordCount < 30 || wordCount > 100) {
                  return 'Must be between 30 and 100 words';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RecipeCategory>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items:
                  RecipeCategory.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => selectedCategory = val!),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveAndNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(bRadius),
                ),
              ),
              child: SizedBox(
                height: 50,
                child: Center(
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}
