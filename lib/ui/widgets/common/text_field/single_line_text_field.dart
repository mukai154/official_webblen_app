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
  final Function()? onFieldSubmitted;
  final TextInputType? keyboardType;
  SingleLineTextField({
    required this.controller,
    required this.hintText,
    required this.textLimit,
    required this.isPassword,
    this.enabled,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      //height: 38,
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
        onFieldSubmitted:
            onFieldSubmitted == null ? null : (val) => onFieldSubmitted!(),
        keyboardType: keyboardType == null ? TextInputType.text : keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          hintText: hintText,
          hintStyle: TextStyle(
            color: appFontColorAlt(),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
