import 'package:flutter/material.dart';
import 'package:webblen/constants/time.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class TimeDropdown extends StatelessWidget {
  final String? selectedTime;
  final Function(String?) onChanged;
  TimeDropdown({required this.selectedTime, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: DropdownButton(
          icon: Container(),
          isDense: true,
          underline: Container(),
          value: selectedTime,
          items: timeList.map((String val) {
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
