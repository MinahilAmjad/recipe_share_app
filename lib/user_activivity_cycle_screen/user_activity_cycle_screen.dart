import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_share_cooking_app/screen/home_screen/home_screen.dart';
import 'package:recipe_share_cooking_app/screen/initial_screen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityCycleScreen extends StatefulWidget {
  @override
  _UserActivityCycleScreenState createState() =>
      _UserActivityCycleScreenState();
}

class _UserActivityCycleScreenState extends State<UserActivityCycleScreen> {
  bool _isLoggedIn = false;

  String recipeId = '';

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  void _checkUserLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // currently signed in??
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in
      setState(() {
        _isLoggedIn = true;
      });
    } else {
      // User is not signed in
      setState(() {
        _isLoggedIn = false;
      });
    }

    // If the user previously logged in mark isLoggedin
    if (isLoggedIn) {
      prefs.setBool('isLoggedIn', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? HomeScreen() : SplashScreen();
  }
}
