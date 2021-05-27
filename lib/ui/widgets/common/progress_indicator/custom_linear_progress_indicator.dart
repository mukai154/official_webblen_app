import 'package:flutter/material.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';

class CustomLinearProgressIndicator extends StatelessWidget {
  final Color? color;

  const CustomLinearProgressIndicator({this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      widthFactor: 1,
      child: SizedBox(
        height: 1,
        width: screenWidth(context),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color?>(
            color == null ? Colors.black38 : color,
          ),
        ),
      ),
    );
  }
}
