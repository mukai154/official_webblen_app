import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class MultiLineTextField extends StatelessWidget {
  final bool enabled;
  final TextEditingController controller;
  final String hintText;
  final String initialValue;
  MultiLineTextField({@required this.enabled, @required this.controller, @required this.hintText, @required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        enabled: enabled,
        initialValue: initialValue,
        controller: controller,
        cursorColor: appFontColorAlt(),
        maxLines: null,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
