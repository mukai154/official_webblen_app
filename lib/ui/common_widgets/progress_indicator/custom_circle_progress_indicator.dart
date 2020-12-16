import 'package:flutter/material.dart';

class CustomCircleProgressIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const CustomCircleProgressIndicator({this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size == null ? 20 : size,
      width: size == null ? 20 : size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color == null ? Color(0xffCC4113) : color,
        ),
      ),
    );
  }
}
