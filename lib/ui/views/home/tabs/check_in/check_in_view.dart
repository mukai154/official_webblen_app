import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';

import 'check_in_view_model.dart';

class CheckInView extends StatelessWidget {
  final WebblenUser? user;
  CheckInView({this.user});

  Widget head(CheckInViewModel model) {
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
                  onPressed: () => model.showAddContentOptions(),
                  icon: Icon(FontAwesomeIcons.plus, color: appIconColor(), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget body(CheckInViewModel model) {
    return Expanded(
      child: ZeroStateView(
        imageAssetName: "map_pins",
        imageSize: 250,
        header: "No Events Found",
        subHeader: "Find Events and Check Into them to Earn WBLN",
        mainActionButtonTitle: "Explore Events",
        mainAction: () {},
        secondaryActionButtonTitle: null,
        secondaryAction: null,
        refreshData: () async {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckInViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      viewModelBuilder: () => locator<CheckInViewModel>(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                head(model),
                body(model),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
