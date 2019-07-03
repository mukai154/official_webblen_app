import 'package:flutter/material.dart';

class Logo extends StatelessWidget {

  final double imageRadius;

  Logo(this.imageRadius);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'image',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: imageRadius,
        child: Image.asset('assets/images/webblen_logo.png'),
      ),
    );
  }
}