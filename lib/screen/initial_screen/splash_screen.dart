import 'package:flutter/material.dart';
import 'package:recipe_share_cooking_app/screen/credentials/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLogo = false;
  bool _showText1 = false;
  bool _showText2 = false;
  bool _showProgressIndicator = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _showLogo = true;
      });
      //  first text
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _showText1 = true;
        });
        //2nd text
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            _showText2 = true;
          });
          // circular progress
          Future.delayed(Duration(seconds: 7), () {
            setState(() {
              _showProgressIndicator = true;
            });
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LogInScreen()),
              );
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Logo
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: _showLogo ? 1.0 : 0.0,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 300,
                  width: 300,
                ),
              ),
            ),
            // 1st Text
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  opacity: _showText1 ? 1.0 : 0.0,
                  child: Transform.rotate(
                    angle: _showText1 ? 0.0 : 0.5,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome to recipe share ',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: 'and Food assistant app',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 2nd Text
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: 130),
                child: AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  opacity: _showText2 ? 1.0 : 0.0,
                  child: Transform.rotate(
                    angle: _showText2 ? 0.0 : 0.5,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Discover amazing recipes\n and cooking tips',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Circular Progress Indicator
            if (_showProgressIndicator) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
