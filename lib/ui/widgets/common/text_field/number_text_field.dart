import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class NumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool? enabled;
  NumberTextField({required this.controller, required this.hintText, this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      height: 38,
      child: TextFormField(
        enabled: enabled != null ? enabled : true,
        controller: controller,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
