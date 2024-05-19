import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';

class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({Key? key}) : super(key: key);

  Future<void> shareApp() async {
    // Set the app link and the message to be shared
    final String appLink =
        'https://www.instagram.com/shaheen.businessnetwork?igsh=anQzMmx1cmQ5MHBu';
    final String message = 'Share this app with your friends: $appLink';

    // Share the app link and message using the share dialog
    await FlutterShare.share(
      title: 'Share App',
      text: message,
      linkUrl: appLink,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 228, 228),
        elevation: 0,
        title: Text(
          'Share App',
          style: TextStyle(
              fontSize: 30,
              color: const Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 400,
              height: 300,
            ),
            const Text(
              'Share this app with your friends!',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Additional message for users
            Text(
              'Help us reach more people by\n sharing the app!',
              style: TextStyle(fontSize: 20, color: Colors.black54),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),
            MaterialButton(
              color: Colors.red,
              onPressed: shareApp,
              child: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }
}
