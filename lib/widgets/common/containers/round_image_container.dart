import 'package:flutter/material.dart';

class RoundImageContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;
  RoundImageContainer({
    this.child,
    this.color,
    this.size,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(size / 2),
        ),
        color: color,
      ),
      child: Center(
        child: child,
      ),
    );
  }
}
