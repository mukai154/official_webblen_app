import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  PhoneTextField({required this.controller, required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return //TextFieldContainer(child: Container()
        IntlPhoneField(
      controller: controller,
      showDropdownIcon: false,
      onChanged: (phone) => onChanged(phone.completeNumber),
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
      ),
    );
  }
}
