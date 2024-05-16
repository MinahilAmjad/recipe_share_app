import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipe_share_cooking_app/screen/credentials/login_screen.dart';
import 'package:recipe_share_cooking_app/widgets/custom_button.dart';
import 'package:recipe_share_cooking_app/widgets/custom_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(msg: 'Password reset email sent successfully.');
      Navigator.push(context, MaterialPageRoute(builder: (_) => LogInScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Forget Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                    textEditingController: emailController,
                    prefixIcon: Icons.email_outlined,
                    hintText: 'Enter Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          title: _isLoading
                              ? 'sending request.....'
                              : 'send request',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              String email = emailController.text.trim();
                              resetPassword(context, email);
                            }
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
