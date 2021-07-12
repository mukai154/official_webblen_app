import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/list_builders/list_events/check_in/list_check_in_events.dart';

import 'check_in_view_model.dart';

class CheckInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckInViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: false,
      viewModelBuilder: () => CheckInViewModel(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: model.appBaseViewModel.isBusy
              ? Container()
              : Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CheckInViewHead(),
                      Expanded(
                        child: ListCheckInEvents(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _CheckInViewHead extends HookViewModelWidget<CheckInViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CheckInViewModel model) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Check In",
            style: TextStyle(
              color: appFontColor(),
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => model.customBottomSheetService.showAddContentOptions(),
                  icon: Icon(FontAwesomeIcons.plus, color: appIconColor(), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
