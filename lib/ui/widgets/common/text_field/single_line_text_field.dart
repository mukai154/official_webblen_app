import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class SingleLineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? textLimit;
  final bool isPassword;
  final bool? enabled;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  SingleLineTextField(
      {required this.controller,
      required this.hintText,
      required this.textLimit,
      required this.isPassword,
      this.enabled,
      this.onChanged,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      height: 38,
      child: TextFormField(
        enabled: enabled != null ? enabled : true,
        controller: controller,
        obscureText: isPassword,
        inputFormatters: textLimit == null
            ? []
            : [
                LengthLimitingTextInputFormatter(textLimit),
              ],
        style: TextStyle(color: appFontColor()),
        cursorColor: appFontColor(),
        onChanged: onChanged == null ? null : (val) => onChanged!(val),
        keyboardType: keyboardType == null ? TextInputType.text : keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
