import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 228, 228),
        title: Text(
          'About Us',
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to RecipeShare and Food Assistant!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Our mission is to provide you with a platform where you can discover and share your favorite recipes with the world. Whether you are a seasoned chef or a beginner in the kitchen, RecipeShare has something for everyone. With our Food Assistant feature, you can access personalized cooking tips, ingredient substitutions, and more to enhance your culinary experience.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Connect with Us on Social Media:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                // Facebook button
                SocialAuthButton(
                  icon: Icons.facebook,
                  onPressed: () {
                    launcherLink('https://www.facebook.com/');
                  },
                ),
                SizedBox(width: 16),
                // Instagram button
                SocialAuthButton(
                  icon: FontAwesomeIcons.instagram,
                  onPressed: () {
                    launcherLink(
                        'https://www.instagram.com/mi.nahil7617?igsh=aWsxN3JmOGhwcXk0');
                  },
                ),
                SizedBox(width: 16),
                // TikTok button
                SocialAuthButton(
                  icon: Icons.tiktok,
                  onPressed: () {
                    launcherLink('https://www.tiktok.com/');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void launcherLink(String url) async {
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch $url: $e';
    }
  }
}

class SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SocialAuthButton({
    required this.icon,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 40,
      color: Colors.black, // Set the color to black
      onPressed: onPressed,
    );
  }
}
