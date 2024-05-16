import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final IconData? prefixIcon;
  final TextEditingController? textEditingController;
  final String? Function(String?)? validator;
  final Widget? suffixWidget;
  final bool? obscureText;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    this.hintText,
    this.prefixIcon,
    this.textEditingController,
    this.validator,
    this.suffixWidget,
    this.obscureText = false,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText!,
      validator: validator,
      controller: textEditingController,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color.fromARGB(255, 198, 59, 59)),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(prefixIcon),
        suffix: suffixWidget,
      ),
    );
  }
}
