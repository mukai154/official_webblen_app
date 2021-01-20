import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/enums/init_error_status.dart';
import 'package:webblen/ui/views/home/init_error_views/location_error/location_error_view.dart';
import 'package:webblen/ui/views/home/init_error_views/network_error/network_error_view.dart';
import 'package:webblen/ui/views/home/tabs/check_in/check_in_view.dart';
import 'package:webblen/ui/views/home/tabs/home/home_view.dart';
import 'package:webblen/ui/views/home/tabs/messages/messages_view.dart';
import 'package:webblen/ui/views/home/tabs/profile/profile_view.dart';
import 'package:webblen/ui/views/home/tabs/wallet/wallet_view.dart';
import 'package:webblen/ui/widgets/common/navigation/nav_bar/custom_nav_bar.dart';
import 'package:webblen/ui/widgets/common/navigation/nav_bar/custom_nav_bar_item.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

import 'home_nav_view_model.dart';

class HomeNavView extends StatelessWidget {
  Widget getViewForIndex(int index, HomeNavViewModel model) {
    switch (index) {
      case 0:
        return HomeView(
          user: model.user,
          initialCityName: model.initialCityName,
          initialAreaCode: model.initialAreaCode,
        );
      case 1:
        return MessagesView(user: model.user);
      case 2:
        return CheckInView();
      case 3:
        return WalletView();
      case 4:
        return ProfileView(user: model.user);
      default:
        return HomeView(
          user: model.user,
          initialCityName: model.initialCityName,
          initialAreaCode: model.initialAreaCode,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeNavViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => HomeNavViewModel(),
      builder: (context, model, child) => Scaffold(
        body: model.isBusy
            ? Container(
                color: appBackgroundColor(),
                child: Center(
                  child: CustomCircleProgressIndicator(
                    color: appActiveColor(),
                    size: 32,
                  ),
                ),
              )
            : model.initErrorStatus == InitErrorStatus.network
                ? NetworkErrorView(
                    tryAgainAction: () => model.initialize(),
                  )
                : model.initErrorStatus == InitErrorStatus.location
                    ? LocationErrorView(
                        tryAgainAction: () => model.initialize(),
                      )
                    : getViewForIndex(model.navBarIndex, model),
        bottomNavigationBar: CustomNavBar(
          navBarItems: [
            CustomNavBarItem(
              onTap: () => model.setNavBarIndex(0),
              iconData: FontAwesomeIcons.home,
              isActive: model.navBarIndex == 0 ? true : false,
            ),
            CustomNavBarItem(
              onTap: () => model.setNavBarIndex(1),
              iconData: FontAwesomeIcons.envelope,
              isActive: model.navBarIndex == 1 ? true : false,
            ),
            CustomNavBarItem(
              onTap: () => model.setNavBarIndex(2),
              iconData: FontAwesomeIcons.mapMarkerAlt,
              isActive: model.navBarIndex == 2 ? true : false,
            ),
            CustomNavBarItem(
              onTap: () => model.setNavBarIndex(3),
              iconData: FontAwesomeIcons.wallet,
              isActive: model.navBarIndex == 3 ? true : false,
            ),
            CustomNavBarItem(
              onTap: () => model.setNavBarIndex(4),
              iconData: FontAwesomeIcons.user,
              isActive: model.navBarIndex == 4 ? true : false,
            ),
          ],
        ),
      ),
    );
  }
}
