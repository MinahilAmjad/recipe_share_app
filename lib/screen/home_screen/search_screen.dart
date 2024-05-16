import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_share_cooking_app/screen/home_screen/main_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recipes = [];
  final List<String> popularRecipes = [
    'Pizza',
    'Chocolate Cake',
    'Burger',
    'Shawarma'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 240, 240),
        title: const Text('Search Food'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _updateHintText(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search for recipes...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      String query = _searchController.text.trim();
                      if (query.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainScreen(searchQuery: query),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Popular recipes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: recipes.map((recipe) {
                      return MaterialButton(
                        color: const Color.fromARGB(255, 243, 227, 227),
                        onPressed: () {
                          _navigateToMainScreenWithQuery(recipe);
                        },
                        child: Text(recipe),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 70),
            Text(
              'Popular Recipes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: popularRecipes.map((recipe) {
                return MaterialButton(
                  onPressed: () {
                    _navigateToMainScreenWithQuery(recipe);
                  },
                  child: Text(recipe),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  //  navigate to MainScreen
  void _navigateToMainScreenWithQuery(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(searchQuery: query),
      ),
    );
  }

//hint text
  void _updateHintText(String value) async {
    if (value.isNotEmpty) {
      try {
        // fetch recipes
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('recipes')
            .where('recipeName', isGreaterThanOrEqualTo: value)
            .where('recipeName', isLessThan: value + 'z')
            .limit(5)
            .get();

        setState(() {
          // Update
          recipes = querySnapshot.docs
              .map((doc) => doc['recipeName'] as String)
              .toList();
        });
      } catch (error) {
        print('Error fetching recipes: $error');
      }
    } else {
      setState(() {
        recipes.clear();
      });
    }
  }
}
