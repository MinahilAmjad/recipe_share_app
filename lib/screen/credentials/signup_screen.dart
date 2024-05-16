import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipe_share_cooking_app/models/user_model/user_model.dart';
import 'package:recipe_share_cooking_app/screen/home_screen/home_screen.dart';
import 'package:recipe_share_cooking_app/widgets/account_selection.dart';
import 'package:recipe_share_cooking_app/widgets/custom_button.dart';
import 'package:recipe_share_cooking_app/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passwordC = TextEditingController();
  final TextEditingController _rePassC = TextEditingController();
  bool _isObscureText = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> addUserToFirestore(
      User? user, String fullName, String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'uid': user?.uid,
        'userName': fullName,
        'email': email,
        'password': _passwordC.text,
      });
    } catch (e) {
      print('Error adding user to Firestore: $e');
    }
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String fullName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      ///addUserToFirestore
      await addUserToFirestore(user, fullName, email);

      return user;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  Future<void> _signUpCredentials() async {
    if (_nameC.text.isEmpty ||
        _emailC.text.isEmpty ||
        _passwordC.text.isEmpty ||
        _rePassC.text.isEmpty) {
      Fluttertoast.showToast(msg: 'All fields should not be empty');
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_passwordC.text != _rePassC.text) {
        Fluttertoast.showToast(msg: "Passwords do not match!");
        return;
      }

      try {
        setState(() {
          _isLoading = true;
        });

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailC.text, password: _passwordC.text);

        if (userCredential.user != null) {
          UserModel userModel = UserModel(
            uid: FirebaseAuth.instance.currentUser!.uid,
            displayName: FirebaseAuth.instance.currentUser!.displayName,
            email: _emailC.text,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userModel.uid)
              .set(userModel.toMap());

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          Fluttertoast.showToast(
              msg: 'Email is already in use. Please sign in.');
        } else {
          Fluttertoast.showToast(msg: 'Error: ${e.message}');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: 'Please fill in all the required fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: [
            const Text(
              'WELCOME TO Recipe Sharing and Food Assistant App',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    textEditingController: _nameC,
                    prefixIcon: Icons.person_outline,
                    hintText: 'Enter Name',
                    validator: (v) {
                      if (v!.isEmpty) {
                        return 'Field Should Not be Empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    textEditingController: _emailC,
                    prefixIcon: Icons.email_outlined,
                    hintText: 'Enter Email',
                    validator: (v) {
                      if (v!.isEmpty) {
                        return 'Field Should Not be Empty';
                      } else if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                          .hasMatch(v)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
                  _isLoading
                      ? CircularProgressIndicator()
                      : CustomButton(
                          title: 'Signup',
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  User? user = await signUpWithEmailAndPassword(
                                    _emailC.text,
                                    _passwordC.text,
                                    _nameC.text,
                                  );
                                  if (user != null) {
                                    // Registration successful
                                    Fluttertoast.showToast(
                                      msg: "Signup Successfull!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.9),
                                      textColor: Colors.black,
                                      fontSize: 16.0,
                                    );

                                    // Navigate to the home screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HomeScreen(),
                                      ),
                                    );
                                  } else {
                                    // Registration failed
                                    Fluttertoast.showToast(
                                      msg: "Signup Failed!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.9),
                                      textColor: Colors.black,
                                      fontSize: 16.0,
                                    );
                                  }
                                },
                        ),
                  SizedBox(height: 10),
                  AccountSelection(
                    title: 'Already have an account?',
                    buttonTitle: 'LOGIN',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
