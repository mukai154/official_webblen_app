import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_linear_progress_indicator.dart';
import 'package:webblen/ui/widgets/list_builders/list_events/search/list_full_event_search_results.dart';
import 'package:webblen/ui/widgets/list_builders/list_live_streams/search/list_full_live_stream_search_results.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts/search/list_full_post_search_results.dart';
import 'package:webblen/ui/widgets/list_builders/list_users/list_users.dart';
import 'package:webblen/ui/widgets/search/search_field.dart';

import 'all_search_results_view_model.dart';

class AllSearchResultsView extends StatefulWidget {
  final String? searchTerm;
  AllSearchResultsView({this.searchTerm});
  @override
  _AllSearchResultsViewState createState() => _AllSearchResultsViewState();
}

class _AllSearchResultsViewState extends State<AllSearchResultsView> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  Widget noResultsFound(AllSearchResultsViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: CustomText(
        text: "No Results for \"${widget.searchTerm}\"",
        textAlign: TextAlign.center,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: appFontColorAlt(),
      ),
    );
  }

  Widget head(AllSearchResultsViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SearchField(
            heroTag: 'search',
            onTap: () => model.customNavigationService.navigateBack(),
            enabled: false,
            textEditingController: model.searchTextController,
            onChanged: (val) {},
            autoFocus: false,
            onFieldSubmitted: (val) {},
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => model.customNavigationService.navigateToBase(),
            child: CustomText(
              text: "Cancel",
              textAlign: TextAlign.right,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: appTextButtonColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget body(AllSearchResultsViewModel model) {
    return TabBarView(
      controller: _tabController,
      children: [
        ListFullPostSearchResults(searchTerm: widget.searchTerm!),
        ListFullLiveStreamSearchResults(searchTerm: widget.searchTerm!),
        ListFullEventSearchResults(searchTerm: widget.searchTerm!),
        model.userResults.isNotEmpty
            ? ListUsers(
                refreshData: model.refreshUsers,
                userResults: model.userResults,
                pageStorageKey: PageStorageKey('user-results'),
                scrollController: model.userScrollController,
              )
            : noResultsFound(model),
      ],
    );
  }

  Widget tabBar() {
    return WebblenAllSearchResultsTabBar(
      tabController: _tabController,
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
    return ViewModelBuilder<AllSearchResultsViewModel>.reactive(
      disposeViewModel: true,
      onModelReady: (model) => model.initialize(widget.searchTerm),
      viewModelBuilder: () => AllSearchResultsViewModel(),
      builder: (context, model, child) => Scaffold(
        body: Container(
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
                  model.isBusy ? CustomLinearProgressIndicator(color: appActiveColor()) : Container(),
                  SizedBox(height: 8),
                  Expanded(
                    child: body(model),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
