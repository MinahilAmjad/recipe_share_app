import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/recipe_detail_screen.dart';

class MainScreen extends StatelessWidget {
  final String searchQuery;

  const MainScreen({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results: $searchQuery'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('recipeName', isEqualTo: searchQuery)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<DocumentSnapshot> recipes = snapshot.data!.docs;
          if (recipes.isEmpty) {
            return Center(
              child: Text('No recipes found for $searchQuery'),
            );
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              DocumentSnapshot recipe = recipes[index];
              String recipeName = recipe['recipeName'];
              String imageUrl = recipe['imageUrls'][1];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        recipeId: recipe.id,
                        userUid: '',
                      ),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipeName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
