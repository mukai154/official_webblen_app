import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CancelNewEventButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  CancelNewEventButton({
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 4.0,
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.times,
            color: color,
            size: 24.0,
          ),
          onPressed: onTap != null
              ? () => onTap()
              : () {
                  print('Not set yet');
                },
        ),
      ],
    );
  }
}
