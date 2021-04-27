import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/users/following/user_following_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/list_builders/list_users.dart';
import 'package:webblen/ui/widgets/search/search_field.dart';

class UserFollowingView extends StatelessWidget {
  Widget appBar(UserFollowingViewModel model) {
    return CustomAppBar().basicAppBar(
      title: "Following",
      showBackButton: true,
      bottomWidgetHeight: 20,
      bottomWidget: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: FollowerFollowingSearchField(
          autoFocus: false,
          textEditingController: model.searchTextController,
          onChanged: (val) {
            if (val.trim().isEmpty) {
              model.clearSearchResults();
            }
          },
          onFieldSubmitted: (val) => model.querySearchResults(val),
        ),
      ),
    );
  }

  Widget listResults(UserFollowingViewModel model) {
    return model.userResults.isEmpty
        ? ZeroStateView(
            imageAssetName: "search",
            imageSize: 200,
            opacity: 0.3,
            header: "No Recent Accounts Found",
            subHeader: "You are not following anyone",
            refreshData: null,
          )
        : listUserResults(model);
  }

  Widget listUserResults(UserFollowingViewModel model) {
    return ListUsers(
      refreshData: model.refreshUsers,
      userResults: model.userSearchResults.isEmpty ? model.userResults : model.userSearchResults,
      pageStorageKey: null,
      scrollController: model.scrollController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserFollowingViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => UserFollowingViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: appBar(model) as PreferredSizeWidget?,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: screenHeight(context),
            color: appBackgroundColor(),
            child: model.isBusy ? Container() : listResults(model),
          ),
        ),
      ),
    );
  }
}
