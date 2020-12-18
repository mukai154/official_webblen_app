import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';

class CustomNavBar extends StatelessWidget {
  final List<Widget> navBarItems;

  CustomNavBar({this.navBarItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(16),
        //   topRight: Radius.circular(16),
        // ),
        color: appBackgroundColor(),
        boxShadow: [
          BoxShadow(
            color: appShadowColor(),
            spreadRadius: 0.5,
            blurRadius: 1.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navBarItems,
      ),
    );
  }
}
