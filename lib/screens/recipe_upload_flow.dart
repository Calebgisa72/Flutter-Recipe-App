import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/forms/basic_info_form.dart';
import 'package:flutter_recipe_app/forms/image_upload.dart';
import 'package:flutter_recipe_app/forms/ingredients_form.dart';
import 'package:flutter_recipe_app/models/recipe_model.dart';
import 'package:flutter_recipe_app/providers/app_main_provider.dart';
import 'package:flutter_recipe_app/utils/constants.dart';

class RecipeFormFlow extends StatefulWidget {
  final bool edit;
  final DocumentSnapshot<Object?>? documentSnapshot;
  const RecipeFormFlow({super.key, required this.edit, this.documentSnapshot});

  @override
  State<RecipeFormFlow> createState() => _RecipeFormFlowState();
}

class _RecipeFormFlowState extends State<RecipeFormFlow> {
  int _currentStep = 0;
  RecipeFormData? formData;
  bool _isLoading = true;
  late String userId;

  @override
  void initState() {
    super.initState();
    if (widget.edit && widget.documentSnapshot == null) {
      throw ArgumentError(
        'documentSnapshot must be provided when edit is true.',
      );
    }
    userId = AppMainProvider.of(context, listen: false).userId;

    _initializeFormData();
    _isLoading = false;
  }

  Future<void> _initializeFormData() async {
    try {
      if (widget.edit) {
        formData = RecipeFormData.fromDocument(widget.documentSnapshot, userId);
      } else {
        formData = RecipeFormData(userId: userId);
      }
    } catch (e) {
      debugPrint('Error initializing form: $e');
    }
  }

  void _nextStep() {
    setState(() => _currentStep += 1);
  }

  void _prevStep() {
    setState(() => _currentStep -= 1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text(
                'Loading Uploading Page',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (formData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to initialize form'),
              ElevatedButton(
                onPressed: _initializeFormData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final tabProvider = AppMainProvider.of(context);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text(
          widget.edit ? 'Edit your Recipe' : 'Create a Recipe',
          style: TextStyle(fontWeight: FontWeight.w500, color: foreGround),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 17, color: Colors.red),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(bRadius),
                    ),
                    backgroundColor: secondary,
                    title: Text(
                      'Are you sure?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Do you really want to cancel? Your changes will be lost.',
                      style: TextStyle(fontSize: 16),
                    ),
                    actionsAlignment: MainAxisAlignment.end,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('No', style: TextStyle(color: foreGround)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          tabProvider.setSelectedTab(0);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Yes',
                          style: TextStyle(color: Colors.white),
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
      body: IndexedStack(
        index: _currentStep,
        children: [
          BasicInfoForm(
            formData: formData!,
            onNext: _nextStep,
            edit: widget.edit,
          ),
          ImageUpload(
            formData: formData!,
            onNext: _nextStep,
            onBack: _prevStep,
            edit: widget.edit,
          ),
          IngredientsForm(
            formData: formData!,
            onBack: _prevStep,
            onSubmit: () async {
              try {
                if (widget.edit) {
                  await formData!.submit(widget.documentSnapshot!.id);
                } else {
                  await formData!.submit();
                }
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(bRadius),
                      ),
                      backgroundColor: secondary,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🥳', style: TextStyle(fontSize: 80)),
                          SizedBox(height: 10),
                          Text(
                            'Upload Success',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: foreGround,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your recipe has been uploaded,\nyou can see it on your profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: foreGround,
                            ),
                          ),
                        ],
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            tabProvider.setSelectedTab(0);
                          },
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
                                'Back To Home',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error submitting recipe: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class RecipeFormData {
  String name;
  int cal;
  RecipeCategory category;
  String image;
  String rating;
  int time;
  String description;
  List<Ingredients> ingredients;
  String userId;

  RecipeFormData({
    required this.userId,
    this.name = '',
    this.cal = 0,
    this.category = RecipeCategory.lunch,
    this.image = '',
    this.rating = '',
    this.time = 0,
    this.description = '',
    List<Ingredients>? ingredients,
  }) : ingredients = ingredients ?? [];

  factory RecipeFormData.fromDocument(DocumentSnapshot? doc, String userId) {
    return RecipeFormData(
      userId: userId,
      name: doc?['name'] ?? '',
      cal: doc?['cal'] ?? 0,
      image: doc?['image'] ?? '',
      time: doc?['time'] ?? 0,
      rating: doc?['rating'] ?? '',
      description: doc?['description'] ?? '',
      category:
          doc != null
              ? RecipeCategory.values.firstWhere(
                (e) => e.name == doc['category'],
                orElse: () => RecipeCategory.lunch,
              )
              : RecipeCategory.lunch,
      ingredients:
          doc != null
              ? (doc['ingredients'] as List)
                  .map((i) => Ingredients.fromJson(i))
                  .toList()
              : [],
    );
  }

  Future<void> submit([String? docId]) async {
    final recipe = RecipeModel(
      name: name,
      cal: cal,
      category: category,
      image: image,
      ingredients: ingredients,
      rating: rating,
      time: time,
      description: description,
      userId: userId,
    );

    if (docId != null) {
      await recipe.updateRecipe(docId);
    } else {
      await recipe.createRecipe();
    }
  }
}
