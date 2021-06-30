import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

import 'vertical_schedule_stream_button_model.dart';

class VerticalScheduleStreamButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VerticalScheduleStreamButtonModel>.reactive(
      viewModelBuilder: () => VerticalScheduleStreamButtonModel(),
      builder: (context, model, child) => GestureDetector(
        onTap: () => model.onTap(),
        child: Padding(
          padding: EdgeInsets.only(right: 4),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  model.user.profilePicURL!,
                  filterQuality: FilterQuality.medium,
                  height: double.infinity,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: double.infinity,
                width: 150,
                decoration: BoxDecoration(
                  gradient: CustomColors.livestreamBlockGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: appBackgroundColor(),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      FontAwesomeIcons.plus,
                      color: appFontColor(),
                      size: 14,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: CustomText(
                  text: "Create\nLivestream",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
