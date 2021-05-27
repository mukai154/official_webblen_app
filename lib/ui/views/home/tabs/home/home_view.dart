import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/home/tabs/home/home_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/list_builders/list_events/home/list_home_events.dart';
import 'package:webblen/ui/widgets/list_builders/list_live_streams/home/list_home_live_streams.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts/home/list_home_posts.dart';
import 'package:webblen/ui/widgets/notifications/notification_bell/notification_bell_view.dart';

import 'home_view_model.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      viewModelBuilder: () => locator<HomeViewModel>(),
      builder: (context, model, child) => Container(
        width: screenWidth(context),
        height: screenHeight(context),
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: model.appBaseViewModel.isBusy
                ? Center(
                    child: CustomCircleProgressIndicator(
                      color: appActiveColor(),
                      size: 32,
                    ),
                  )
                : _HomeView(),
          ),
        ),
      ),
    );
  }
}

class _HomeView extends HookViewModelWidget<HomeViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel model) {
    var _tabController = useTabController(initialLength: 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _HomeHead(),
        SizedBox(height: 8),
        WebblenHomePageTabBar(
          tabController: _tabController,
        ),
        SizedBox(height: 8),
        model.cityName.isEmpty
            ? Container()
            : _HomeBody(
                tabController: _tabController,
              ),
      ],
    );
  }
}

class _HomeHead extends HookViewModelWidget<HomeViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                model.isBusy ? "" : "${model.cityName}",
                style: TextStyle(
                  color: appFontColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NotificationBellView(uid: model.user.id),
                IconButton(
                  iconSize: 20,
                  onPressed: () => model.customBottomSheetService.openFilter(),
                  icon: Icon(FontAwesomeIcons.slidersH, color: appIconColor()),
                ),
                IconButton(
                  iconSize: 20,
                  onPressed: () => model.customBottomSheetService.showAddContentOptions(),
                  icon: Icon(FontAwesomeIcons.plus, color: appIconColor()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final TabController tabController;
  _HomeBody({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      //width: screenWidth(context),
      child: DefaultTabController(
        length: 3,
        child: TabBarView(
          controller: tabController,
          children: [
            ///FOR YOU
            // ListForYouContent(
            //   showPostOptions: (post) => model.showContentOptions(content: post),
            //   showEventOptions: (event) => model.showContentOptions(content: event),
            //   showStreamOptions: (stream) => model.showContentOptions(content: stream),
            // ),

            ///POSTS
            ListHomePosts(),

            ///STREAMS & VIDEO
            ListHomeLiveStreams(),

            ///EVENTS
            ListHomeEvents(),
          ],
        ),
      ),
    );
  }
}
