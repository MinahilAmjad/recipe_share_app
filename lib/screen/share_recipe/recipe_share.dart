import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ShareRecipeScreen extends StatefulWidget {
  const ShareRecipeScreen({Key? key}) : super(key: key);

  @override
  _ShareRecipeScreenState createState() => _ShareRecipeScreenState();
}

class _ShareRecipeScreenState extends State<ShareRecipeScreen> {
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _difficultyLevelController =
      TextEditingController();
  bool isSharing = false;

  List<String> _recipeCategories = [
    'Pizza',
    'Chicken',
    'Nihari',
    'Cake',
    'Other'
  ];

  List<String> _difficultyLevels = [
    'Easy',
    'Intermediate',
    'Difficult',
    'Expert'
  ];
  List<String> _cuisineTypes = [
    'Italian',
    'Mexican',
    'Indian',
    'Chinese',
    'Japanese',
    'French',
    'American',
    'Mediterranean',
    'Other'
  ];

  //categories
  Map<String, List<String>> _recipesMap = {
    'Pizza': ['Margherita', 'Pepperoni', 'Vegetarian'],
    'Chicken': ['Grilled Chicken', 'Chicken Curry', 'Chicken Alfredo'],
    'Nihari': ['Beef Nihari', 'Chicken Nihari'],
    'Cake': ['Chocolate Cake', 'Vanilla Cake', 'Red Velvet Cake'],
    'Other': [],
  };

  String _selectedCategory = 'Pizza';
  String _selectedDifficultyLevel = 'Easy';
  String _selectedCuisineType = 'Italian';

  List<XFile> images = [];

  bool isUploading = false;
  void _updateRecipeName(String category) {
    if (_recipesMap.containsKey(category) &&
        _recipesMap[category]!.isNotEmpty) {
      setState(() {
        _recipeNameController.text = _recipesMap[category]![0];
      });
    } else {
      setState(() {
        _recipeNameController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 100,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/food.jpg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: [..._recipeCategories].map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                  _updateRecipeName(value);
                });
              },
            ),
            const SizedBox(height: 16.0),
            //recipe name
            TextFormField(
              controller: _recipeNameController,
              decoration: InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                  borderSide: const BorderSide(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            //ingredentials
            TextFormField(
              controller: _ingredientsController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Ingredients',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                  borderSide: const BorderSide(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            //instructions
            TextFormField(
              controller: _instructionsController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Instructions',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                  borderSide: const BorderSide(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _cookingTimeController,
              decoration: InputDecoration(
                labelText: 'Cooking Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                  borderSide: const BorderSide(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            //difficulty level
            DropdownButtonFormField<String>(
              value: _selectedDifficultyLevel,
              items: _difficultyLevels.map((level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficultyLevel = value!;
                  _difficultyLevelController.text = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Difficulty Level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                  borderSide: const BorderSide(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16.0),
            //cuisine type
            DropdownButtonFormField<String>(
              value: _selectedCuisineType,
              items: _cuisineTypes.map((cuisine) {
                return DropdownMenuItem<String>(
                  value: cuisine,
                  child: Text(cuisine),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCuisineType = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Cuisine Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                  borderSide: const BorderSide(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            //image pick
            MaterialButton(
              color: const Color(0xFFC8291D),
              child: const Text(
                "Pick Images",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                pickImage();
              },
            ),
            const SizedBox(height: 10),
            if (images.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                  ),
                  itemCount: images.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Image.file(
                              File(images[index].path),
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _removeImage(index);
                            },
                            icon: const Center(
                              child: Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveRecipe();
              },
              child:
                  isSharing ? CircularProgressIndicator() : const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedSharingDateTime() {
    DateTime sharingDateTime = DateTime.now();
    String formattedSharingDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(sharingDateTime);
    return formattedSharingDateTime;
  }

  void _removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    try {
      setState(() {
        isSharing = true;
      });
      // Upload images to Firebase Storage and get  URLs
      List<String> imageUrls = await uploadImagesToFirebase(images);

      // Get current user ID
      String recipeId = FirebaseAuth.instance.currentUser!.uid;

      // Save recipe data to Firebase Firestore with  generated recipeId
      DocumentReference recipeRef =
          await FirebaseFirestore.instance.collection('recipes').add({
        'recipeName': _recipeNameController.text,
        'ingredients': _ingredientsController.text,
        'instructions': _instructionsController.text,
        'cookingTime': _cookingTimeController.text,
        'difficultyLevel': _difficultyLevelController.text,
        'cuisineType': _selectedCuisineType,
        'imageUrls': imageUrls,
        'sharingDateTime': _getFormattedSharingDateTime(),
        'recipeId': recipeId,
      });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe Shared Successfully")),
      );
      setState(() {
        isSharing = false;
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. ${e.toString()}")),
      );
      setState(() {
        isSharing = false;
      });
    }
  }

  Future<List<String>> uploadImagesToFirebase(List<XFile> images) async {
    List<String> imageUrls = [];
    try {
      for (var imageFile in images) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now()}.jpg');
        TaskSnapshot uploadTask =
            await storageRef.putFile(File(imageFile.path));
        String imageUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }
      return imageUrls;
    } catch (e) {
      print('Error uploading images: $e');
      return [];
    }
  }

  void pickImage() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      if (pickedFiles != null) {
        images.addAll(pickedFiles);
      } else {
        print('No images selected.');
      }
    });
  }
}
