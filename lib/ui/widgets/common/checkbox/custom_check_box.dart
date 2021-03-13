import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';

class CustomCheckbox extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onChanged;

  CustomCheckbox({@required this.initialValue, @required this.onChanged});

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: Checkbox(
          visualDensity: VisualDensity.compact,
          activeColor: CustomColors.darkMountainGreen,
          value: isChecked,
          onChanged: (val) {
            setState(() {
              isChecked = val;
            });
            widget.onChanged(val);
          }),
    );
  }
}

class CustomDetailedCheckbox extends StatefulWidget {
  final String header;
  final String subHeader;
  final bool initialValue;
  final Function(bool) onChanged;

  CustomDetailedCheckbox({@required this.header, @required this.subHeader, @required this.initialValue, @required this.onChanged});

  @override
  _CustomDetailedCheckboxState createState() => _CustomDetailedCheckboxState();
}

class _CustomDetailedCheckboxState extends State<CustomDetailedCheckbox> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                widget.header,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
              ),
              CustomCheckbox(initialValue: isChecked, onChanged: (val) => widget.onChanged(val))
            ],
          ),
          Transform.translate(
            offset: Offset(0, -8),
            child: Text(
              widget.subHeader,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: appFontColorAlt(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
