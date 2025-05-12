import 'package:flutter/material.dart';

class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFB2DFDB).withOpacity(0.7),
              const Color(0xFFF48FB1).withOpacity(0.7),
              const Color(0xFFB39DDB).withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
