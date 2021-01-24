import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/list_builders/list_streams.dart';
import 'package:webblen/ui/widgets/list_builders/list_users.dart';
import 'package:webblen/ui/widgets/search/search_field.dart';

import 'explore_view_model.dart';

class ExploreView extends StatefulWidget {
  final WebblenUser user;
  ExploreView({this.user});
  @override
  _ExploreViewState createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> with SingleTickerProviderStateMixin {
  TabController _tabController;

  Widget noDataFound(String dataType) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: CustomText(
        text: "No $dataType Found",
        textAlign: TextAlign.center,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: appFontColorAlt(),
      ),
    );
  }

  Widget head(ExploreViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SearchField(
            heroTag: 'search',
            onTap: () => model.navigateToSearchView(),
            enabled: false,
            textEditingController: null,
          ),
          IconButton(
            onPressed: null, //() => model.navigateToCreateCauseView(),
            icon: Icon(FontAwesomeIcons.plus, color: appIconColor(), size: 20),
          ),
        ],
      ),
    );
  }

  Widget body(ExploreViewModel model) {
    return TabBarView(
      controller: _tabController,
      children: [
        model.streamResults.isNotEmpty
            ? ListStreams(
                refreshData: model.refreshStreams,
                dataResults: model.streamResults,
                pageStorageKey: PageStorageKey('explore-streams'),
                scrollController: model.streamScrollController,
              )
            : Container(), //noResultsFound(),
        model.eventResults.isNotEmpty
            ? ListStreams(
                refreshData: model.refreshEvents,
                dataResults: model.eventResults,
                pageStorageKey: PageStorageKey('explore-events'),
                scrollController: model.eventScrollController,
              )
            : Container(), //noResultsFound(),
        model.userResults.isNotEmpty
            ? ListUsers(
                refreshData: model.refreshUsers,
                userResults: model.userResults,
                pageStorageKey: PageStorageKey('explore-users'),
                scrollController: model.userScrollController,
              )
            : Container(), //noResultsFound(),
      ],
    );
  }

  Widget tabBar() {
    return WebblenExplorePageTabBar(
      tabController: _tabController,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ExploreViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => locator<ExploreViewModel>(),
      builder: (context, model, child) => Container(
        height: screenHeight(context),
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                head(model),
                verticalSpaceSmall,
                tabBar(),
                verticalSpaceSmall,
                Expanded(
                  child: body(model),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
