import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/venue_size_and_descriptions.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class EventVenueSizeSlider extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  EventVenueSizeSlider({@required this.initialValue, @required this.onChanged});
  @override
  _EventVenueSizeSliderState createState() => _EventVenueSizeSliderState();
}

class _EventVenueSizeSliderState extends State<EventVenueSizeSlider> {
  double sliderVal = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      String val = widget.initialValue;
      if (val == "Small") {
        sliderVal = 1;
      } else if (val == "Medium") {
        sliderVal = 2;
      } else if (val == "Large") {
        sliderVal = 3;
      } else if (val == "Huge") {
        sliderVal = 4;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String sizeName = venueSizeAndDescriptions.keys.toList()[sliderVal.toInt() - 1];
    String sizeDescription = venueSizeAndDescriptions.values.toList()[sliderVal.toInt() - 1];

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SfSlider(
            min: 1.0,
            max: 4.0,
            value: sliderVal,
            interval: 1,
            stepSize: 1,
            showTicks: true,
            showLabels: false,
            enableTooltip: false,
            activeColor: appActiveColor(),
            inactiveColor: appDividerColor(),
            onChanged: (val) {
              setState(() {
                sliderVal = val;
              });
              widget.onChanged(sizeName.toLowerCase());
            },
          ),
          CustomText(
            text: sizeName,
            textAlign: TextAlign.center,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: appFontColor(),
          ),
          verticalSpaceTiny,
          CustomText(
            text: sizeDescription,
            textAlign: TextAlign.center,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: appFontColorAlt(),
          ),
        ],
      ),
    );
  }
}
