import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_share_cooking_app/provider/user_provider.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/recipe_detail_screen.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/see_all_recipes.dart';
import 'package:recipe_share_cooking_app/screen/home_screen/search_screen.dart';
import 'package:recipe_share_cooking_app/screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userUid = FirebaseAuth.instance.currentUser!.uid;
  late UserProvider userProvider;

  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 228, 228),
        title: Text('HomeScreen'),
                automaticallyImplyLeading: false,

      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('recipes').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No recipes available');
                }

                // group recipes by name
                Map<String, List<QueryDocumentSnapshot>> groupedRecipes = {};
                snapshot.data!.docs.forEach((recipe) {
                  String recipeName = recipe['recipeName'];
                  if (!groupedRecipes.containsKey(recipeName)) {
                    groupedRecipes[recipeName] = [];
                  }
                  groupedRecipes[recipeName]!.add(recipe);
                });

                // sisplay three recipes  category on the home screen
                List<Widget> homeRecipesWidgets = [];
                groupedRecipes.entries.forEach((entry) {
                  String categoryName = entry.key;
                  List<QueryDocumentSnapshot> recipes =
                      entry.value.take(2).toList();

                  //   list tile
                  List<Widget> categoryRecipeTiles = recipes.map((recipe) {
                    List<dynamic> imageUrls = recipe['imageUrls'];
                    String? imageUrl =
                        imageUrls.isNotEmpty ? imageUrls[0] : null;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(
                                recipeId: recipe.id, userUid: userUid),
                          ),
                        );
                      },
                      child: Container(
                        height: 250,
                        width: 150,
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 243, 227, 227),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
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
                    );
                  }).toList();

                  homeRecipesWidgets.add(
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SeeAllRecipesScreen(
                                        recipes: groupedRecipes[categoryName]!,
                                        category: categoryName,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('See All'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            children: categoryRecipeTiles,
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  );
                });

                return Column(
                  children: homeRecipesWidgets,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
              break;
            case 2:
              // Navigate to UserProfileScreen with the profile data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
