import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recipe_share_cooking_app/provider/user_provider.dart';
import 'package:recipe_share_cooking_app/screen/profiles/profileSee_all_buton_screen.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/modify_recipe.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/recipe_detail_screen.dart';

import 'package:recipe_share_cooking_app/screen/profiles/edit_profile_screen.dart';
import 'package:recipe_share_cooking_app/screen/settings/settings_screen.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/recipe_share.dart';

import 'package:url_launcher/url_launcher.dart';

class UserProfileScreen extends StatefulWidget {
  // final String userUid;

  const UserProfileScreen();

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String userUid = FirebaseAuth.instance.currentUser!.uid;

  List<DocumentSnapshot> likedRecipes = [];
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).setUserUid(userUid);
    Provider.of<UserProvider>(context, listen: false).fetchUserData();
  }

  String _getFormattedSharingDateTime() {
    DateTime sharingDateTime = DateTime.now();
    String formattedSharingDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(sharingDateTime);
    return formattedSharingDateTime;
  }

  void _toggleLikeStatus(DocumentSnapshot recipeSnapshot, bool isLiked) {
    FirebaseFirestore.instance
        .collection('liked_recipes')
        .doc(userUid)
        .collection('recipes')
        .doc(recipeSnapshot.id)
        .update({'liked': isLiked}).then((_) {
      setState(() {
        if (isLiked) {
          likedRecipes.add(recipeSnapshot);
        } else {
          likedRecipes.removeWhere((recipe) => recipe.id == recipeSnapshot.id);
        }
      });
    }).catchError((error) {
      print("Failed to update like status: $error");
    });
  }

  void _removeLikedRecipe(String recipeId) {
    FirebaseFirestore.instance
        .collection('liked_recipes')
        .doc(userUid)
        .collection('recipes')
        .doc(recipeId)
        .delete()
        .then((value) {
      setState(() {
        likedRecipes.removeWhere((recipe) => recipe.id == recipeId);
      });
    }).catchError((error) {
      print("Failed to remove recipe: $error");
    });
  }

  void _showRemoveRecipeDialog(String recipeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Unlike Recipe"),
          content: Text("Are you sure you want to unlike this recipe?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 240, 240),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('profiles')
                .doc(userUid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final profileData =
                  snapshot.data?.data() as Map<String, dynamic>?;

              final userProvider = Provider.of<UserProvider>(context);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: profileData != null &&
                                profileData.containsKey('imageUrl')
                            ? NetworkImage(profileData['imageUrl'])
                            : null,
                        child: profileData == null ||
                                !profileData.containsKey('imageUrl')
                            ? Icon(Icons.person, size: 50)
                            : null,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            profileData != null &&
                                    profileData.containsKey('name')
                                ? Text(
                                    'Name: ${profileData['name']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                : SizedBox(),
                            SizedBox(height: 20),
                            IconButton(
                              icon: Row(
                                children: [
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                            255, 34, 124, 37)),
                                  ),
                                  Icon(Icons.edit),
                                ],
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProfileScreen(userUid: userUid),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 5),
                            profileData != null &&
                                    profileData.containsKey('website')
                                ? GestureDetector(
                                    onTap: () {
                                      launch(profileData['website']);
                                    },
                                    child: Text(
                                      'Website: ${profileData['website']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  DefaultTabController(
                    length: 3,
                    child: Expanded(
                      child: Column(
                        children: [
                          TabBar(
                            tabs: [
                              Tab(
                                text: 'CookBook',
                                icon: Icon(Icons.book),
                              ),
                              Tab(
                                text: 'Liked Recipes',
                                icon: Icon(Icons.favorite),
                              ),
                              Tab(
                                text: 'Share Recipe',
                                icon: Icon(Icons.share),
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                //  cookbook tab
                                _buildCookbookTab(),

                                // Liked recipes tab
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('liked_recipes')
                                      .doc(userUid)
                                      .collection('recipes')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return Center(
                                          child: Text('No liked recipes yet'));
                                    }

                                    final List<DocumentSnapshot>
                                        likedRecipeSnapshots =
                                        snapshot.data!.docs;

                                    return GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10.0,
                                      ),
                                      itemCount: likedRecipeSnapshots.length,
                                      itemBuilder: (context, index) {
                                        final DocumentSnapshot
                                            likedRecipeSnapshot =
                                            likedRecipeSnapshots[index];
                                        final Map<String, dynamic> data =
                                            likedRecipeSnapshot.data()
                                                as Map<String, dynamic>;

                                        List<dynamic> imageUrls =
                                            data['imageUrls'];
                                        String? imageUrl = imageUrls.isNotEmpty
                                            ? imageUrls[0]
                                            : null;

                                        return GestureDetector(
                                          onTap: () {
                                            // Navigate to recipe detail screen
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RecipeDetailScreen(
                                                  recipeId:
                                                      likedRecipeSnapshot.id,
                                                  userUid: userUid,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            child: Stack(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height: 120,
                                                        width: 120,
                                                        child: imageUrl != null
                                                            ? Image.network(
                                                                imageUrl,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : null,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        data['recipeName'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  bottom: 3,
                                                  right: 0.6,
                                                  child: PopupMenuButton(
                                                    icon: Icon(Icons.more_vert),
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        child: ListTile(
                                                          leading: Icon(
                                                            Icons.close_rounded,
                                                            color: Colors.black,
                                                          ),
                                                          title: Text(
                                                              'Unlike Recipe'),
                                                          onTap: () {
                                                            _removeLikedRecipe(
                                                                likedRecipeSnapshot
                                                                    .id);
                                                            Navigator.pop(
                                                                context); // Close the menu
                                                          },
                                                        ),
                                                      ),
                                                    ],
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

                                // Share recipe tab
                                _buildShareRecipeTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildCookbookTab() {
    final user = FirebaseAuth.instance.currentUser;
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance
                .collection('recipes')
                .where('recipeId', isEqualTo: user.uid)
                .snapshots()
            : Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No recipes available');
          }

          // Proceed with processing the snapshot data
          Map<String, List<QueryDocumentSnapshot>> groupedRecipes = {};
          snapshot.data!.docs.forEach((recipe) {
            String recipeName = recipe['recipeName'];
            if (!groupedRecipes.containsKey(recipeName)) {
              groupedRecipes[recipeName] = [];
            }
            groupedRecipes[recipeName]!.add(recipe);
          });
          // Display only three recipes per category
          List<Widget> homeRecipesWidgets = [];
          groupedRecipes.entries.forEach((entry) {
            String categoryName = entry.key;
            List<QueryDocumentSnapshot> recipes = entry.value.take(2).toList();

            // list tile for each recipes in the category
            List<Widget> categoryRecipeTiles = recipes.map((recipe) {
              List<dynamic> imageUrls = recipe['imageUrls'];
              String? imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;
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
                child: Stack(
                  children: [
                    Container(
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'view') {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModifyRecipeScreen(
                                  recipeId: recipe.id,
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('recipes')
                                  .doc(recipe.id)
                                  .delete();

                              // Show a success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Recipe deleted successfully'),
                                ),
                              );
                            } catch (error) {
                              // Show an error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to delete recipe: $error'),
                                ),
                              );
                            }
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
                                builder: (context) =>
                                    ProfileSeeAllRecipesScreen(
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
    );
  }

  Widget _buildShareRecipeTab() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShareRecipeScreen(),
            ),
          );
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Share your recipes with\n the community!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Now the time! Click below to\n upload your recipe to share with\n the community',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                height: 150,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.5),
                ),
                child: Icon(
                  Icons.add,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Share a Recipe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
