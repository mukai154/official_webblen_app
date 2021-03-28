import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/search_result.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/search/search_result_view.dart';

class ListEventSearchResults extends StatelessWidget {
  final Function(Map<String, dynamic>) onSearchTermSelected;
  final List<SearchResult> results;
  final ScrollController scrollController;
  final bool isScrollable;

  ListEventSearchResults({@required this.onSearchTermSelected, @required this.results, @required this.isScrollable, @required this.scrollController});

  Widget listResults() {
    return ListView.builder(
      controller: scrollController,
      physics: isScrollable ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: true,
      shrinkWrap: true,
      padding: EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return EventSearchResultView(
          onTap: () => onSearchTermSelected(results[index].toMap()),
          searchResult: results[index],
          displayBottomBorder: index == results.length - 1 ? false : true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isScrollable
        ? Container(
            height: screenHeight(context),
            color: appBackgroundColor(),
            child: listResults(),
          )
        : listResults();
  }
}
