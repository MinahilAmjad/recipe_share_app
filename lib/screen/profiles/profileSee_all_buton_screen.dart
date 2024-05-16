import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/modify_recipe.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/recipe_detail_screen.dart';

class ProfileSeeAllRecipesScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> recipes;
  final String category;

  const ProfileSeeAllRecipesScreen(
      {Key? key, required this.recipes, required this.category})
      : super(key: key);

  @override
  State<ProfileSeeAllRecipesScreen> createState() =>
      _ProfileSeeAllRecipesScreenState();
}

class _ProfileSeeAllRecipesScreenState
    extends State<ProfileSeeAllRecipesScreen> {
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
                // Navigate to recipe details screen if needed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(
                      recipeId: recipe.id,
                      userUid: userUid,
                    ),
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'view') {
                              // Navigate to recipe detail screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                    recipeId: recipe.id,
                                    userUid: userUid,
                                  ),
                                ),
                              );
                            } else if (value == 'modify') {
                              // Navigate to modify recipe screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModifyRecipeScreen(
                                    recipeId: recipe.id,
                                  ),
                                ),
                              );
                            } else if (value == 'delete') {
                              // Show delete confirmation dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Delete Recipe"),
                                    content: Text(
                                        "Are you sure you want to delete this recipe?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Delete recipe
                                          await FirebaseFirestore.instance
                                              .collection('recipes')
                                              .doc(recipe.id)
                                              .delete();
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'view',
                              child: ListTile(
                                leading: Icon(Icons.remove_red_eye),
                                title: Text('View Recipe'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'modify',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Modify Recipe'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete Recipe'),
                              ),
                            ),
                          ],
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
