import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/views/home/tabs/check_in/check_in_view.dart';
import 'package:webblen/ui/views/home/tabs/home/home_view.dart';
import 'package:webblen/ui/views/home/tabs/messages/messages_view.dart';
import 'package:webblen/ui/views/home/tabs/profile/profile_view.dart';
import 'package:webblen/ui/views/home/tabs/wallet/wallet_view.dart';
import 'package:webblen/ui/widgets/common/navigation/nav_bar/custom_nav_bar.dart';
import 'package:webblen/ui/widgets/common/navigation/nav_bar/custom_nav_bar_item.dart';

import 'home_nav_view_model.dart';

class HomeNavView extends StatelessWidget {
  Widget getViewForIndex(int index, WebblenUser user) {
    switch (index) {
      case 0:
        return HomeView();
      case 1:
        return MessagesView(user: user);
      case 2:
        return CheckInView();
      case 3:
        return WalletView();
      case 4:
        return ProfileView(user: user);
      default:
        return HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeNavViewModel>.reactive(
      viewModelBuilder: () => HomeNavViewModel(),
      builder: (context, model, child) => Scaffold(
        body: model.isBusy ? Container() : getViewForIndex(model.navBarIndex, model.user),
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
