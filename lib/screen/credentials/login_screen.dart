import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipe_share_cooking_app/screen/credentials/forgetpassword.dart';
import 'package:recipe_share_cooking_app/screen/credentials/signup_screen.dart';
import 'package:recipe_share_cooking_app/screen/home_screen/home_screen.dart';
import 'package:recipe_share_cooking_app/widgets/account_selection.dart';
import 'package:recipe_share_cooking_app/widgets/custom_text_field.dart';

import '../../widgets/custom_button.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passwordC = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscureText = true;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String recipeId = '';
  Future<void> _loginCredentials() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailC.text, password: _passwordC.text);

        if (userCredential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(),
            ),
          ).then((_) {
            setState(() {
              _isLoading = false;
            });
          });
        }
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: e.message ?? 'An error occurred');
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 240, 240),
        title: const Text('Login',
            style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Container(
                          height: size.height * 1.0,
                          width: size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                'WELCOME TO Recipe Sharing and Food Assistant App',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CircleAvatar(
                                radius: 100,
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/food.jpg',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              CustomTextField(
                                textEditingController: _emailC,
                                prefixIcon: Icons.email_outlined,
                                hintText: 'Enter Email',
                                validator: (v) {
                                  if (v!.isEmpty) {
                                    return 'Email should not be empty';
                                  } else if (!RegExp(
                                          r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                                      .hasMatch(v)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              Container(
                                height: 70,
                                child: CustomTextField(
                                  textEditingController: _passwordC,
                                  prefixIcon: Icons.password_outlined,
                                  obscureText: _isObscureText,
                                  hintText: 'Enter Password',
                                  validator: (v) {
                                    if (v!.isEmpty) {
                                      return 'Password should not be empty';
                                    } else if (v.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  suffixWidget: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isObscureText = !_isObscureText;
                                      });
                                    },
                                    icon: Icon(
                                      _isObscureText
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              _isLoading
                                  ? CircularProgressIndicator()
                                  : CustomButton(
                                      title: 'LOGIN',
                                      onPressed: _isLoading
                                          ? null
                                          : () async {
                                              _loginCredentials();
                                            }),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) {
                                        return const ForgetPasswordScreen();
                                      }),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                  ),
                                ),
                              ),
                              AccountSelection(
                                title: "Don't have an Account?",
                                buttonTitle: 'CREATE ACCOUNT',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) {
                                      return const SignUpScreen();
                                    }),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
