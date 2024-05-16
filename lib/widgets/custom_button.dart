import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? title;
  final void Function()? onPressed;

  const CustomButton({
    super.key,
    this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 40,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Color.fromARGB(255, 239, 237, 237),
      onPressed: onPressed,
      child: Center(
        child: Text(title.toString()),
      ),
    );
  }
}
