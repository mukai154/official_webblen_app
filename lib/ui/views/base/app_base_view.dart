import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/enums/init_error_status.dart';
import 'package:webblen/ui/views/base/init_error_views/under_maintenance/under_maintenance_error_view.dart';
import 'package:webblen/ui/views/base/init_error_views/update_required/update_required_view.dart';
import 'package:webblen/ui/views/home/tabs/check_in/check_in_view.dart';
import 'package:webblen/ui/views/home/tabs/home/home_view.dart';
import 'package:webblen/ui/views/home/tabs/profile/profile_view.dart';
import 'package:webblen/ui/views/home/tabs/search/recent_search_view.dart';
import 'package:webblen/ui/views/home/tabs/wallet/wallet_view.dart';
import 'package:webblen/ui/widgets/common/navigation/nav_bar/custom_nav_bar.dart';
import 'package:webblen/ui/widgets/common/navigation/nav_bar/custom_nav_bar_item.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/mini_video_player/mini_video_player_view.dart';

import 'app_base_view_model.dart';
import 'init_error_views/location_error/location_error_view.dart';
import 'init_error_views/network_error/network_error_view.dart';

class AppBaseView extends StatelessWidget {
  final String? page;
  AppBaseView({@PathParam() this.page});

  final List<Widget> views = [
    HomeView(),
    RecentSearchView(),
    CheckInView(),
    WalletView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AppBaseViewModel>.reactive(
      disposeViewModel: false,
      fireOnModelReadyOnce: true,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(page),
      viewModelBuilder: () => locator<AppBaseViewModel>(),
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
                    tryAgainAction: () => model.initialize(page),
                  )
                : model.initErrorStatus == InitErrorStatus.underMaintenance
                    ? UnderMaintenanceErrorView(
                        tryAgainAction: () => model.initialize(page),
                      )
                    : model.initErrorStatus == InitErrorStatus.updateRequired
                        ? UpdateRequiredView(
                            tryAgainAction: () => model.initialize(page),
                          )
                        : model.initErrorStatus == InitErrorStatus.location
                            ? LocationErrorView(
                                tryAgainAction: () => model.initialize(page),
                              )
                            : Stack(
                                children: [
                                  views[model.navBarIndex],
                                  MiniVideoPlayerView(),
                                ],
                              ),
        bottomNavigationBar: CustomNavBar(
          navBarItems: [
            CustomNavBarItem(
              onTap: () => model.setNavBarIndex(0),
              iconData: FontAwesomeIcons.home,
              isActive: model.navBarIndex == 0 ? true : false,
            ),
            CustomNavBarItem(
              onTap: () => model.setNavBarIndex(1),
              iconData: FontAwesomeIcons.search,
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
