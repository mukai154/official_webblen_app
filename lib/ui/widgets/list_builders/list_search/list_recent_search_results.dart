import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/search/search_result_view.dart';

class ListRecentSearchResults extends StatelessWidget {
  final Function(String) onSearchTermSelected;
  final List? searchTerms;
  final ScrollController? scrollController;
  final bool isScrollable;

  ListRecentSearchResults({required this.onSearchTermSelected, required this.searchTerms, required this.isScrollable, required this.scrollController});

  Widget listResults() {
    return Material(
      type: MaterialType.transparency,
      child: ListView.builder(
        controller: scrollController,
        physics: isScrollable ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: searchTerms!.length,
        itemBuilder: (context, index) {
          return RecentSearchTermView(
            onSearchTermSelected: () => onSearchTermSelected(searchTerms![index]),
            searchTerm: searchTerms![index],
            displayBottomBorder: index == searchTerms!.length - 1 ? false : true,
            displayIcon: true,
          );
        },
      ),
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
