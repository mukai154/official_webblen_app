import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:webblen/styles/flat_colors.dart';

class CreateNewsPostAction extends StatelessWidget {
  final VoidCallback action;

  CreateNewsPostAction({
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Padding(
        padding: EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          FontAwesomeIcons.edit,
          color: FlatColors.darkGray,
          size: 20.0,
        ),
      ),
    );
  }
}

class CreateEventAction extends StatelessWidget {
  final VoidCallback action;

  CreateEventAction({
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Padding(
        padding: EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          FontAwesomeIcons.calendarPlus,
          color: FlatColors.darkGray,
          size: 20.0,
        ),
      ),
    );
  }
}
