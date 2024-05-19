import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_share_cooking_app/screen/credentials/login_screen.dart';
import 'package:recipe_share_cooking_app/screen/settings/about_us.dart';
import 'package:recipe_share_cooking_app/screen/settings/faqs.dart';
import 'package:recipe_share_cooking_app/screen/settings/feedback_screen.dart';
import 'package:recipe_share_cooking_app/screen/settings/healthy_diet_screen.dart';
import 'package:recipe_share_cooking_app/screen/settings/rate_app.dart';
import 'package:recipe_share_cooking_app/screen/settings/share_app.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 228, 228),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Privacy',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text('About Us'),
            leading: Icon(Icons.info),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AboutUs(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Recipes FAQs'),
            leading: Icon(Icons.help),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Recipe_Creationfaq(),
                ),
              );
            },
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'More',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text('Rate App'),
            leading: Icon(Icons.star),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RateAppScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Healthy Diet'),
            leading: Icon(Icons.food_bank),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HealthyDietScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Share App'),
            leading: Icon(Icons.share),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShareAppScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Feedback'),
            leading: Icon(Icons.comment),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FeedbackScreen(),
                ),
              );
            },
          ),
          _listTileComponent(
            context,
            () => _showLogoutConfirmationDialog(context),
            Icons.logout,
            'LogOut',
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _listTileComponent(
    BuildContext context,
    void Function()? onTap,
    IconData leadingIcon,
    String title,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(leadingIcon),
      title: Text(title),
      trailing: Icon(Icons.forward_outlined),
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) {
                    return LogInScreen();
                  }),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
