import 'package:flutter/material.dart';

class SettingsIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final IconData iconData;
  final Color color;
  SettingsIconButton({this.onTap, this.title, this.iconData, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Expanded(
        child: Container(
          color: Colors.transparent,
          height: 48,
          child: Center(
            child: Row(
              children: [
                Icon(iconData, color: color, size: 18),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
