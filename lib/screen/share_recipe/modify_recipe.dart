import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ModifyRecipeScreen extends StatefulWidget {
  final String recipeId;

  const ModifyRecipeScreen({Key? key, required this.recipeId})
      : super(key: key);

  @override
  _ModifyRecipeScreenState createState() => _ModifyRecipeScreenState();
}

class _ModifyRecipeScreenState extends State<ModifyRecipeScreen> {
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _difficultyLevelController =
      TextEditingController();
  final TextEditingController _cuisineTypeController = TextEditingController();
  List<XFile> images = [];
  List<XFile>? initialImages;
  bool _isModifying = false;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  void fetchRecipeDetails() {
    FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _recipeNameController.text = data['recipeName'];
          _ingredientsController.text = data['ingredients'];
          _instructionsController.text = data['instructions'];
          _cookingTimeController.text = data['cookingTime'];
          _difficultyLevelController.text = data['difficultyLevel'];
          _cuisineTypeController.text = data['cuisineType'];
          if (data.containsKey('imageUrls')) {
            List<String> imageUrls = data['imageUrls'];
            initialImages = imageUrls.map((url) => XFile(url)).toList();
            images.clear();
            images.addAll(initialImages!);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Recipe'),
      ),
      body: _isModifying ? _buildProgressIndicator() : _buildModifyScreen(),
    );
  }

  Widget _buildModifyScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _recipeNameController,
            decoration: InputDecoration(labelText: 'Recipe Name'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _ingredientsController,
            maxLines: null,
            decoration: InputDecoration(labelText: 'Ingredients'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _instructionsController,
            maxLines: null,
            decoration: InputDecoration(labelText: 'Instructions'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _cookingTimeController,
            decoration: InputDecoration(labelText: 'Cooking Time'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _difficultyLevelController,
            decoration: InputDecoration(labelText: 'Difficulty Level'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _cuisineTypeController,
            decoration: InputDecoration(labelText: 'Cuisine Type'),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              pickImage();
            },
            child: Text('Pick Images'),
          ),
          SizedBox(height: 10),
          Text('Images:', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8.0),
          if (images.isNotEmpty)
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    key: ValueKey(images[index].path),
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(images[index].path),
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ElevatedButton(
            onPressed: () {
              saveChanges();
            },
            child: Text('Modify Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void saveChanges() async {
    setState(() {
      _isModifying = true;
    });

    String recipeName = _recipeNameController.text;
    String ingredients = _ingredientsController.text;
    String instructions = _instructionsController.text;
    String cookingTime = _cookingTimeController.text;
    String difficultyLevel = _difficultyLevelController.text;
    String cuisineType = _cuisineTypeController.text;
    List<String> imageUrls = [];

    for (XFile image in images) {
      if (!image.path.startsWith('http')) {
        String fileName = image.path.split('/').last;
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('recipe_images/$fileName')
            .putFile(File(image.path));
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } else {
        imageUrls.add(image.path);
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .update({
        'recipeName': recipeName,
        'ingredients': ingredients,
        'instructions': instructions,
        'cookingTime': cookingTime,
        'difficultyLevel': difficultyLevel,
        'cuisineType': cuisineType,
        'imageUrls': imageUrls,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe details modified successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to modify recipe details.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isModifying = false;
      });
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

  //add new and remove old images
  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final XFile item = images.removeAt(oldIndex);
      images.insert(newIndex, item);
    });
  }
}
