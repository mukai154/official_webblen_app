import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/styles/flat_colors.dart';

class UserDetailsBadge extends StatelessWidget {

  final String badgeType;
  final double size;

  UserDetailsBadge({this.badgeType, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: badgeType == "communityBuilder"
            ? FlatColors.casandoraYellow
            : badgeType == "friend"
            ? FlatColors.webblenRed
            : FlatColors.lightAmericanGray,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: badgeType == "communityBuilder"
            ? Icon(FontAwesomeIcons.hammer, size: 10.0, color: Colors.white)
            : badgeType == "friend"
            ? Icon(FontAwesomeIcons.solidHeart, size: 10.0, color: Colors.white)
            : Container(),
      )
    );
  }
}