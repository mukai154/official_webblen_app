import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/home/tabs/home/home_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts.dart';
import 'package:webblen/ui/widgets/notifications/notification_bell/notification_bell_view.dart';

import 'home_view_model.dart';

class HomeView extends StatefulWidget {
  final WebblenUser user;
  final String initialCityName;
  final String initialAreaCode;
  HomeView({this.user, this.initialCityName, this.initialAreaCode});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  TabController _tabController;

  Widget head(HomeViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 200,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                " ${model.cityName}",
                style: TextStyle(
                  color: appFontColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              ),
            ),
          ),
          Row(
            children: [
              NotificationBellView(uid: widget.user.uid),
              horizontalSpaceSmall,
              IconButton(
                iconSize: 20,
                onPressed: () => model.openFilter(),
                icon: Icon(FontAwesomeIcons.slidersH, color: appIconColor()),
              ),
              IconButton(
                iconSize: 20,
                onPressed: () => model.navigateToCreateCauseView(),
                icon: Icon(FontAwesomeIcons.plus, color: appIconColor()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget tabBar() {
    return WebblenHomePageTabBar(
      tabController: _tabController,
    );
  }

  Widget body(HomeViewModel model) {
    return TabBarView(
      controller: _tabController,
      children: [
        ListPosts(
          refreshData: model.refreshPosts,
          postResults: model.postResults,
          pageStorageKey: PageStorageKey('home-posts'),
          scrollController: model.scrollController,
        ),
        Container(),
        Container(),
        Container(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(
        tabController: _tabController,
        currentUser: widget.user,
        initialCityName: widget.initialCityName,
        initialAreaCode: widget.initialAreaCode,
      ),
      viewModelBuilder: () => locator<HomeViewModel>(),
      builder: (context, model, child) => Container(
        height: screenHeight(context),
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                head(model),
                SizedBox(height: 4),
                tabBar(),
                SizedBox(height: 4),
                Expanded(
                  child: model.isBusy
                      ? Center(
                          child: CustomCircleProgressIndicator(
                            color: appActiveColor(),
                            size: 32,
                          ),
                        )
                      : DefaultTabController(
                          length: 4,
                          child: body(model),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
