import 'package:flutter/material.dart';

class MyCustomButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final double height;
  final Color color;

  final double? minWidth;

  const MyCustomButton(
      {super.key,
      required this.text,
      this.onPressed,
      required this.height,
      required this.color,
      this.minWidth});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,

      height: height,
      minWidth: minWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
