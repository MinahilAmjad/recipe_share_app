import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:recipe_share_cooking_app/screen/profile_screen.dart';
import 'package:recipe_share_cooking_app/screen/share_recipe/comment_screen.dart';

import 'package:url_launcher/url_launcher.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  final String userUid;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
    required this.userUid,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  DocumentSnapshot? userData;
  String? _userImageUrl;
  final _userNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _bioController = TextEditingController();
  List<Comment> _comments = [];

  bool _isLiked = false;
  bool _isDataFetched = false;

  int _likesCount = 0;
  void _showImageZoomDialog(
      BuildContext context, List<String> imageUrls, int initialIndex) {
    final Size size = MediaQuery.of(context).size;
    final double maxHeight = size.height - 100.0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: PhotoViewGallery.builder(
            scrollDirection: Axis.horizontal,
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[index]),
                initialScale: PhotoViewComputedScale.contained,
                maxScale: maxHeight,
                heroAttributes: PhotoViewHeroAttributes(tag: index),
              );
            },
            itemCount: imageUrls.length,
            pageController: PageController(initialPage: initialIndex),
            onPageChanged: (index) {},
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _checkIfLiked();
    _fetchLikesCount();

    fetchUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchUserData() async {
    try {
      final userDataSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.userUid)
          .get();

      if (userDataSnapshot.exists) {
        setState(() {
          _isDataFetched = true;
          userData = userDataSnapshot;
          _userNameController.text = userData!['name'];
          _websiteController.text = userData!['website'];
          _bioController.text = userData!['bio'];
          _userImageUrl = userData!['imageUrl'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _toggleLike(
    String recipeName,
    String ingredients,
    String instructions,
    String cookingTime,
    String difficultyLevel,
    String cuisineType,
    List<String> imageUrls,
  ) async {
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      final likedRecipeSnapshot = await FirebaseFirestore.instance
          .collection('liked_recipes')
          .doc(currentUserUid)
          .collection('recipes')
          .doc(widget.recipeId)
          .get();

      if (_isLiked) {
        return;
      }

      setState(() {
        _isLiked = true;
        _likesCount++;

        FirebaseFirestore.instance
            .collection('liked_recipes')
            .doc(currentUserUid)
            .collection('recipes')
            .doc(widget.recipeId)
            .set({
          'liked': true,
          'recipeName': recipeName,
          'ingredients': ingredients,
          'instructions': instructions,
          'cookingTime': cookingTime,
          'difficultyLevel': difficultyLevel,
          'cuisineType': cuisineType,
          'imageUrls': imageUrls,
        });
      });

      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .update({'likesCount': _likesCount});
    } catch (e) {
      print('Error toggling like: $e');
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          _likesCount++;
        } else {
          _likesCount--;
        }
      });
    }
  }

  void _fetchLikesCount() {
    FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.userUid)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          setState(() {
            _likesCount = data['likesCount'] ?? 0;
          });
        }
      }
    });
  }

  void _shareRecipeDetails(
    String recipeName,
    String ingredients,
    String instructions,
    String cookingTime,
    String difficultyLevel,
    String cuisineType,
    List<String> imageUrls,
  ) async {
    String text = "Check out this delicious recipe!\n\n";
    text += "Recipe Name: $recipeName\n\n";
    text += "Ingredients:\n$ingredients\n\n";
    text += "Instructions:\n$instructions\n\n";
    text += "Cooking Time: $cookingTime\n\n";
    text += "Difficulty Level: $difficultyLevel\n\n";
    text += "Cuisine Type: $cuisineType\n\n";

    try {
      await FlutterShare.share(
        title: 'Share Recipe',
        text: text,
        chooserTitle: 'Share via',
      );
    } catch (e) {
      print('Error sharing recipe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 240, 240),
        title: Text('Recipe Detail'),
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('recipes')
                .doc(widget.recipeId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('No data available'));
              }

              final Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: _isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        if (snapshot.hasData) {
                          final Map<String, dynamic> data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          _toggleLike(
                            data['recipeName'],
                            data['ingredients'],
                            data['instructions'],
                            data['cookingTime'],
                            data['difficultyLevel'],
                            data['cuisineType'],
                            List<String>.from(data['imageUrls'] ?? []),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Text('$_likesCount'),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection('recipes')
                  .doc(widget.recipeId)
                  .get();
              if (snapshot.exists) {
                final Map<String, dynamic> data = snapshot.data()!;
                final String recipeName = data['recipeName'];
                final String ingredients = data['ingredients'];
                final String instructions = data['instructions'];
                final String cookingTime = data['cookingTime'];
                final String difficultyLevel = data['difficultyLevel'];
                final String cuisineType = data['cuisineType'];
                final List<String> imageUrls =
                    List<String>.from(data['imageUrls'] ?? []);
                _shareRecipeDetails(
                  recipeName,
                  ingredients,
                  instructions,
                  cookingTime,
                  difficultyLevel,
                  cuisineType,
                  imageUrls,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.recipeId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          final Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          final String recipeName = data['recipeName'];
          final String ingredients = data['ingredients'];
          final String instructions = data['instructions'];
          final String cookingTime = data['cookingTime'];
          final String difficultyLevel = data['difficultyLevel'];
          final String cuisineType = data['cuisineType'];
          final List<String> imageUrls =
              List<String>.from(data['imageUrls'] ?? []);

          // Fetch the timestamp
          final Timestamp? timestamp = data['timestamp'] as Timestamp?;

          final formattedDateTime = timestamp != null
              ? DateFormat('dd-MM-yyyy HH:mm').format(timestamp.toDate())
              : 'Unknown';

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                  child: Column(
                children: [
                  Text(
                    'User Details',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 200,
                    height: 6,
                    color: const Color.fromARGB(255, 180, 10, 10),
                  ),
                  SizedBox(height: 7),
                  Container(
                    width: 170,
                    height: 5,
                    color: Colors.black,
                  ),
                  SizedBox(height: 7),
                  Container(
                    width: 140,
                    height: 4,
                    color: Color.fromARGB(255, 7, 126, 70),
                  ),
                  SizedBox(height: 5),
                ],
              )),
              SizedBox(height: 40),
              if (_isDataFetched) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _userImageUrl != null
                            ? NetworkImage(_userImageUrl!) as ImageProvider
                            : AssetImage('assets/images/user_image.jpg'),
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${_userNameController.text}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Website',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                GestureDetector(
                  onTap: () async {
                    if (_websiteController.text.isNotEmpty) {
                      try {
                        await launch(_websiteController.text);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error opening URL: $e'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('URL is empty'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    _websiteController.text,
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Bio',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text(
                            _bioController.text,
                            style: TextStyle(fontSize: 18),
                            maxLines: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Recipe Details',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 200,
                      height: 6,
                      color: const Color.fromARGB(255, 180, 10, 10),
                    ),
                    SizedBox(height: 7),
                    Container(
                      width: 170,
                      height: 5,
                      color: Colors.black,
                    ),
                    SizedBox(height: 7),
                    Container(
                      width: 140,
                      height: 4,
                      color: Color.fromARGB(255, 7, 126, 70),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              SizedBox(height: 40),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(197, 0, 0, 0)),
                  children: [
                    TextSpan(
                      text: 'Recipe Name: \n ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    TextSpan(
                      text: '$recipeName',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    WidgetSpan(
                      child: SizedBox(height: 10),
                    ),
                    TextSpan(
                      text: 'Ingredients: \n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    ...List.generate(
                      ingredients.split('\n').length,
                      (index) => TextSpan(
                        text:
                            '${index + 1}. ${ingredients.split('\n')[index]}\n',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Instructions:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    ...List.generate(
                      instructions.split('\n').length,
                      (index) => TextSpan(
                        text:
                            '${index + 1}. ${instructions.split('\n')[index]}\n',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Cooking Time: \n ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    TextSpan(text: '$cookingTime'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Difficulty Level: \n',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    TextSpan(text: '$difficultyLevel'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Cuisine Type: \n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    TextSpan(text: '$cuisineType'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Recipe Images',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 200,
                      height: 6,
                      color: const Color.fromARGB(255, 180, 10, 10),
                    ),
                    SizedBox(height: 7),
                    Container(
                      width: 170,
                      height: 5,
                      color: Colors.black,
                    ),
                    SizedBox(height: 7),
                    Container(
                      width: 140,
                      height: 4,
                      color: Color.fromARGB(255, 7, 126, 70),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(border: Border.all()),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int index = 0; index < imageUrls.length; index++)
                        GestureDetector(
                          onTap: () {
                            _showImageZoomDialog(context, imageUrls, index);
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Image.network(
                                imageUrls[index],
                                height: size.height,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(
                        userUid: widget.userUid,
                        recipeId: widget.recipeId,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons
                    .comment), // You can replace Icons.comment with your desired icon
              ),
            ]),
          );
        },
      ),
    );
  }

  String _getFormattedSharingDateTime() {
    DateTime sharingDateTime = DateTime.now();
    String formattedSharingDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(sharingDateTime);
    return formattedSharingDateTime;
  }

  void _checkIfLiked() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final currentUserUid = currentUser.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .collection('likedUsers')
          .doc(currentUserUid)
          .get();

      setState(() {
        _isLiked = snapshot.exists;
      });
    }
  }
}
