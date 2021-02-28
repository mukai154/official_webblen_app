import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class SingleLineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int textLimit;
  final bool isPassword;
  SingleLineTextField({@required this.controller, @required this.hintText, @required this.textLimit, @required this.isPassword});

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        inputFormatters: textLimit == null
            ? []
            : [
                LengthLimitingTextInputFormatter(textLimit),
              ],
        style: TextStyle(color: appFontColor()),
        cursorColor: appFontColor(),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
