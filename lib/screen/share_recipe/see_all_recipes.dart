import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/recipe_detail_screen.dart';

class SeeAllRecipesScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> recipes;
  final String category;

  const SeeAllRecipesScreen(
      {Key? key, required this.recipes, required this.category})
      : super(key: key);

  @override
  State<SeeAllRecipesScreen> createState() => _SeeAllRecipesScreenState();
}

class _SeeAllRecipesScreenState extends State<SeeAllRecipesScreen> {
  late String userUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 240, 240),
        title: Text('All ${widget.category}\n Recipes'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: widget.recipes.length,
          itemBuilder: (BuildContext context, int index) {
            // Extract data for each recipe
            QueryDocumentSnapshot recipe = widget.recipes[index];
            List<dynamic> imageUrls = recipe['imageUrls'];
            String? imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;

            return GestureDetector(
              onTap: () {
                // Navigate to recipe details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(
                        recipeId: recipe.id, userUid: userUid),
                  ),
                );
              },
              child: Container(
                height: 150,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipe['recipeName'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
