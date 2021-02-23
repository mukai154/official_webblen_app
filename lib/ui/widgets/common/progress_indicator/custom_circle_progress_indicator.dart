import 'package:flutter/material.dart';

class CustomCircleProgressIndicator extends StatelessWidget {
  final double size;
  final Color color;

  CustomCircleProgressIndicator({this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size == null ? 20 : size,
      width: size == null ? 20 : size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color == null ? Color(0xffCC4113) : color,
        ),
      ),
    );
  }
}

class AppBarCircleProgressIndicator extends StatelessWidget {
  final Color color;
  final double size;

  AppBarCircleProgressIndicator({@required this.color, @required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Center(
        child: CustomCircleProgressIndicator(
          color: color,
          size: 14,
        ),
      ),
    );
  }
}
