import 'package:flutter/material.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class EventPrivacyDropdown extends StatelessWidget {
  final String? privacy;
  final Function(String?) onChanged;
  EventPrivacyDropdown({required this.privacy, required this.onChanged});

  final List<String> privacyOptions = ['Public', 'Private'];
  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: DropdownButton(
          icon: Container(),
          isDense: true,
          underline: Container(),
          value: privacy,
          items: privacyOptions.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: (dynamic val) => onChanged(val),
        ),
      ),
    );
  }
}
