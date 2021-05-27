import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';

class IconTextField extends StatelessWidget {
  final IconData iconData;
  final TextEditingController controller;
  final String hintText;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final bool? hidden;

  IconTextField({
    required this.iconData,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
    this.hidden,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 8),
        height: 35,
        decoration: BoxDecoration(
          color: appTextFieldContainerColor(),
          border: Border.all(
            width: 1.0,
            color: appBorderColorAlt(),
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Row(
          children: [
            Container(
              child: Icon(
                iconData,
                color: appFontColorAlt(),
                size: 16,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  color: Colors.transparent,
                  child: TextFormField(
                    controller: controller,
                    cursorColor: appFontColor(),
                    textInputAction: TextInputAction.search,
                    onChanged: onChanged == null ? null : (val) => onChanged(val),
                    keyboardType: keyboardType == null ? TextInputType.text : keyboardType,
                    obscureText: hidden != null ? hidden! : false,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 14),
                      hintText: hintText,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
