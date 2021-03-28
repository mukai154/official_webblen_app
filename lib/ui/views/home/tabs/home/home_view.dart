import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/home/tabs/home/home_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/list_builders/list_events.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts.dart';
import 'package:webblen/ui/widgets/list_builders/list_streams.dart';
import 'package:webblen/ui/widgets/notifications/notification_bell/notification_bell_view.dart';

import 'home_view_model.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
              NotificationBellView(uid: model.webblenBaseViewModel.uid),
              horizontalSpaceSmall,
              IconButton(
                iconSize: 20,
                onPressed: () => model.openFilter(),
                icon: Icon(FontAwesomeIcons.slidersH, color: appIconColor()),
              ),
              IconButton(
                iconSize: 20,
                onPressed: () => model.showAddContentOptions(),
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
        ///FOR YOU
        ZeroStateView(
          scrollController: model.scrollController,
          imageAssetName: "mobile_people_group",
          imageSize: 200,
          header: "You are Not Following Anyone",
          subHeader: "Find People and Groups to Follow and Get Involved With",
          mainActionButtonTitle: "Explore People & Groups",
          mainAction: () {},
          secondaryActionButtonTitle: null,
          secondaryAction: null,
          refreshData: () async {},
        ),

        ///POSTS
        model.postResults.isEmpty && !model.loadingPosts
            ? ZeroStateView(
                scrollController: model.scrollController,
                imageAssetName: "umbrella_chair",
                imageSize: 200,
                header: "No Posts in ${model.cityName} Found",
                subHeader: model.postPromo != null
                    ? "Create a Post for ${model.cityName} Now and Earn ${model.postPromo.toStringAsFixed(2)} WBLN!"
                    : "Create a Post for ${model.cityName} Now!",
                mainActionButtonTitle: model.postPromo != null ? "Earn ${model.postPromo.toStringAsFixed(2)} WBLN" : "Create Post",
                mainAction: () => model.createPostWithPromo(),
                secondaryActionButtonTitle: null,
                secondaryAction: null,
                refreshData: () async {},
              )
            : ListPosts(
                currentUID: model.webblenBaseViewModel.uid,
                refreshData: model.refreshPosts,
                postResults: model.postResults,
                pageStorageKey: PageStorageKey('home-posts'),
                scrollController: model.scrollController,
                showPostOptions: (post) => model.showContentOptions(content: post),
              ),

        ///STREAMS & VIDEO
        model.streamResults.isEmpty && !model.loadingStreams
            ? ZeroStateView(
                scrollController: model.scrollController,
                imageAssetName: "video_phone",
                imageSize: 200,
                header: "No Streams in ${model.cityName} Found",
                subHeader: model.streamPromo != null
                    ? "Schedule a Stream for ${model.cityName} Now and Earn ${model.streamPromo.toStringAsFixed(2)} WBLN!"
                    : "Schedule a Stream for ${model.cityName} Now!",
                mainActionButtonTitle: model.streamPromo != null ? "Earn ${model.streamPromo.toStringAsFixed(2)} WBLN" : "Create Stream",
                mainAction: () => model.createStreamWithPromo(),
                secondaryActionButtonTitle: null,
                secondaryAction: null,
                refreshData: () async {},
              )
            : ListLiveStreams(
                refreshData: model.refreshEvents,
                dataResults: model.streamResults,
                pageStorageKey: PageStorageKey('home-events'),
                scrollController: model.scrollController,
                showStreamOptions: (stream) => model.showContentOptions(content: stream),
              ),

        ///EVENTS
        model.eventResults.isEmpty && !model.loadingEvents
            ? ZeroStateView(
                scrollController: model.scrollController,
                imageAssetName: "calendar",
                imageSize: 200,
                header: "No Events in ${model.cityName} Found",
                subHeader: model.eventPromo != null
                    ? "Schedule an Event for ${model.cityName} Now and Earn ${model.eventPromo.toStringAsFixed(2)} WBLN!"
                    : "Schedule an Event for ${model.cityName} Now!",
                mainActionButtonTitle: model.eventPromo != null ? "Earn ${model.eventPromo.toStringAsFixed(2)} WBLN" : "Create Event",
                mainAction: () => model.createEventWithPromo(),
                secondaryActionButtonTitle: null,
                secondaryAction: null,
                refreshData: () async {},
              )
            : ListEvents(
                refreshData: model.refreshEvents,
                dataResults: model.eventResults,
                pageStorageKey: PageStorageKey('home-events'),
                scrollController: model.scrollController,
                showEventOptions: (event) => model.showContentOptions(content: event),
              ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    return ViewModelBuilder<HomeViewModel>.reactive(
      disposeViewModel: false,
      fireOnModelReadyOnce: true,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(
        tabController: _tabController,
      ),
      viewModelBuilder: () => locator<HomeViewModel>(),
      builder: (context, model, child) => Container(
        height: screenHeight(context),
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: model.isBusy
                ? Center(
                    child: CustomCircleProgressIndicator(
                      color: appActiveColor(),
                      size: 32,
                    ),
                  )
                : Column(
                    children: [
                      head(model),
                      SizedBox(height: 4),
                      tabBar(),
                      SizedBox(height: 4),
                      Expanded(
                        child: DefaultTabController(
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
