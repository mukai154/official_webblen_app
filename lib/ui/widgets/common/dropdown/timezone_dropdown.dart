import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/time.dart';

import '../custom_text.dart';

class TimezoneDropdown extends StatelessWidget {
  final String selectedTimezone;
  final Function(String) onChanged;
  TimezoneDropdown({@required this.selectedTimezone, @required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      isExpanded: true,
      icon: Container(),
      underline: Container(),
      value: selectedTimezone,
      items: timezones.map((Map<String, dynamic> item) {
        return DropdownMenuItem<String>(
          value: item['abbr'],
          child: Container(
            width: MediaQuery.of(context).size.width - 32.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CustomText(
                  text: "${item['value']}: ${item['abbr']}",
                  color: item['abbr'] == selectedTimezone ? Colors.blue : appFontColor(),
                  textAlign: TextAlign.left,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: item['text'],
                  color: item['abbr'] == selectedTimezone ? Colors.blue : appFontColor(),
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: (val) => onChanged(val),
    );
  }
}
