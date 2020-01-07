import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class ShakeAnimation extends StatefulWidget {
  final Widget widgetToShake;
  ShakeAnimation({this.widgetToShake});

  @override
  _ShakeAnimationState createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 1,
      ),
    )..addListener(() => setState(() {}));

    animation = Tween<double>(
      begin: 50.0,
      end: 120.0,
    ).animate(animationController);

    animationController.forward();
    animation.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await new Future.delayed(
          const Duration(
            seconds: 7,
          ),
        );
        animationController.reset();
        animationController.forward();
      }
    });
  }

  Vector3 _shake() {
    double progress = animationController.value;
    double offset = sin(progress * pi * 6);
    return Vector3(
      offset * 5,
      1.0,
      0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.translation(_shake()),
      child: widget.widgetToShake,
    );
  }
}
