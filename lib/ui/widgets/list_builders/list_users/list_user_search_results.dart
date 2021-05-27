import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/search_result.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/search/search_result_view.dart';

class ListUsersSearchResults extends StatelessWidget {
  final Function(Map<String, dynamic>) onSearchTermSelected;
  final List? usersFollowing;
  final List<SearchResult> results;
  final ScrollController? scrollController;
  final bool isScrollable;

  ListUsersSearchResults(
      {required this.onSearchTermSelected, required this.results, required this.usersFollowing, required this.isScrollable, required this.scrollController});

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
        return UserSearchResultView(
          onTap: () => onSearchTermSelected({
            'id': results[index].id,
            'username': results[index].name,
          }),
          searchResult: results[index],
          isFollowing: usersFollowing!.contains(results[index].id),
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
