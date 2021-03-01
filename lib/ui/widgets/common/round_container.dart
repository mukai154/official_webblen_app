import 'package:flutter/material.dart';

class RoundContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;
  RoundContainer({
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

class RoundIconContainer extends StatelessWidget {
  final Icon icon;
  final double size;
  final Color color;

  RoundIconContainer({
    this.icon,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(child: icon),
    );
  }
}