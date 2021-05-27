import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/venue_size_and_descriptions.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class EventVenueSizeSlider extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  EventVenueSizeSlider({required this.initialValue, required this.onChanged});
  @override
  _EventVenueSizeSliderState createState() => _EventVenueSizeSliderState();
}

class _EventVenueSizeSliderState extends State<EventVenueSizeSlider> {
  double? sliderVal = 1;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    String sizeName = venueSizeAndDescriptions.keys.toList()[sliderVal!.toInt() - 1];
    String sizeDescription = venueSizeAndDescriptions.values.toList()[sliderVal!.toInt() - 1];

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlutterSlider(
            tooltip: FlutterSliderTooltip(
              disabled: true,
            ),
            handler: FlutterSliderHandler(
              decoration: BoxDecoration(),
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: appBackgroundColor(),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    width: 2,
                    color: appActiveColor(),
                  ),
                ),
              ),
            ),
            trackBar: FlutterSliderTrackBar(
              activeTrackBarHeight: 15,
              inactiveTrackBarHeight: 15,
              inactiveTrackBar: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.black12,
                border: Border.all(
                  width: 3,
                  color: appActiveColor(),
                ),
              ),
              activeTrackBar: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: CustomColors.webblenRed.withOpacity(0.5),
              ),
            ),
            jump: true,
            min: 1,
            max: 4,
            values: [sliderVal!],
            step: FlutterSliderStep(step: 1),
            onDragging: (handlerIndex, lowerValue, upperValue) {
              sliderVal = lowerValue;
              setState(() {});
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
