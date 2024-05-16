import 'package:flutter/material.dart';

class AccountSelection extends StatelessWidget {
  final String? title;
  final String? buttonTitle;
  final void Function()? onPressed;

  const AccountSelection({
    super.key,
    this.title,
    this.buttonTitle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title.toString()),
        TextButton(
          onPressed: onPressed,
          child: Text(
            buttonTitle.toString(),
          ),
        ),
      ],
    );
  }
}
