import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/search/search_view_model.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_linear_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/list_builders/list_recent_search_results.dart';
import 'package:webblen/ui/widgets/list_builders/list_streams_search_results.dart';
import 'package:webblen/ui/widgets/list_builders/list_user_search_results.dart';
import 'package:webblen/ui/widgets/search/search_field.dart';
import 'package:webblen/ui/widgets/search/search_result_view.dart';

class SearchView extends StatelessWidget {
  final String term;
  SearchView({this.term});

  Widget head(BuildContext context, SearchViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SearchField(
            heroTag: 'search',
            onTap: null,
            enabled: true,
            textEditingController: model.searchTextController,
            onChanged: (val) => model.querySearchResults(val),
            onFieldSubmitted: (val) => model.viewAllResultsForSearchTerm(context: context, searchTerm: val),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => model.navigateToPreviousView(),
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

  Widget streamsHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: CustomText(
        text: "Livestreams",
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.left,
        fontSize: 24,
        color: appFontColorAlt(),
      ),
    );
  }

  Widget eventsHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: CustomText(
        text: "Events",
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.left,
        fontSize: 24,
        color: appFontColorAlt(),
      ),
    );
  }

  Widget usersHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: CustomText(
        text: "People",
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.left,
        fontSize: 24,
        color: appFontColorAlt(),
      ),
    );
  }

  Widget eventUserSearchDivider(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 16,
          width: screenWidth(context),
          color: appTextFieldContainerColor(),
        ),
        verticalSpaceSmall,
      ],
    );
  }

  Widget listResults(BuildContext context, SearchViewModel model) {
    return Expanded(
      child: model.streamResults.isEmpty && model.eventResults.isEmpty && model.userResults.isEmpty && model.searchTextController.text.trim().isEmpty
          ? model.webblenBaseViewModel.user.recentSearchTerms == null
              ? ZeroStateView(
                  imageAssetName: "search",
                  imageSize: 200,
                  opacity: 0.3,
                  header: "No Recent Searches Found",
                  subHeader: "Search for anything you'd like",
                  refreshData: null,
                )
              : listRecentResults(context, model)
          : ListView(
              shrinkWrap: true,
              children: [
                model.streamResults.isNotEmpty ? listStreamResults(model) : Container(),
                (model.streamResults.isNotEmpty || model.eventResults.isNotEmpty) && model.userResults.isNotEmpty
                    ? eventUserSearchDivider(context)
                    : Container(),
                model.userResults.isNotEmpty ? listUserResults(model) : Container(),
                model.searchTextController.text.trim().isNotEmpty && !model.isBusy
                    ? ViewAllResultsSearchTermView(
                        onSearchTermSelected: () => model.viewAllResultsForSearchTerm(context: context, searchTerm: model.searchTextController.text.trim()),
                        searchTerm: "View all results for \"${model.searchTextController.text.trim()}\"",
                      )
                    : Container(),
              ],
            ),
    );
  }

  Widget listRecentResults(BuildContext context, SearchViewModel model) {
    return Hero(
      tag: 'recent-searches',
      child: ListRecentSearchResults(
        searchTerms: model.webblenBaseViewModel.user.recentSearchTerms,
        scrollController: null,
        isScrollable: false,
        onSearchTermSelected: (val) => model.viewAllResultsForSearchTerm(context: context, searchTerm: val),
      ),
    );
  }

  Widget listStreamResults(SearchViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        streamsHeader(),
        ListStreamSearchResults(
          results: model.streamResults,
          scrollController: null,
          isScrollable: false,
          onSearchTermSelected: (val) => model.navigateToCauseView(val),
        ),
      ],
    );
  }

  Widget listUserResults(SearchViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        usersHeader(),
        ListUsersSearchResults(
          results: model.userResults,
          usersFollowing: model.webblenBaseViewModel.user.following,
          scrollController: null,
          isScrollable: false,
          onSearchTermSelected: (val) => model.navigateToUserView(val),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchViewModel>.reactive(
      onModelReady: (model) => model.initialize(term: term),
      viewModelBuilder: () => SearchViewModel(),
      builder: (context, model, child) => Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: screenHeight(context),
            color: appBackgroundColor(),
            child: SafeArea(
              child: Container(
                child: Column(
                  children: [
                    head(context, model),
                    verticalSpaceSmall,
                    model.isBusy ? CustomLinearProgressIndicator(color: appActiveColor()) : Container(),
                    SizedBox(height: 8),
                    model.isBusy ? Container() : listResults(context, model),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
