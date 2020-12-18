import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';

class CustomNavBarItem extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;
  final IconData iconData;
  final String label;

  CustomNavBarItem({this.onTap, this.isActive, this.iconData, this.label});
  @override
  Widget build(BuildContext context) {
    Color activeColor = CustomColors.webblenRed;
    Color inactiveColor = Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(top: 4, left: 8, right: 8),
        height: 50,
        width: 50,
        color: Colors.transparent,
        child: Column(
          children: [
            Icon(
              iconData,
              color: isActive ? appIconColor() : appInActiveColorAlt(),
              size: 24,
            ),
            SizedBox(height: 2),
            label == null
                ? Container()
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: isActive ? appIconColor() : appInActiveColorAlt(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
