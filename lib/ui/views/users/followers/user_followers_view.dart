import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/users/followers/user_followers_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/list_builders/list_users.dart';
import 'package:webblen/ui/widgets/search/search_field.dart';

class UserFollowersView extends StatelessWidget {
  Widget appBar(UserFollowersViewModel model) {
    return CustomAppBar().basicAppBar(
      title: "Followers",
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

  Widget listResults(UserFollowersViewModel model) {
    return model.userResults.isEmpty
        ? ZeroStateView(
            imageAssetName: "search",
            imageSize: 200,
            opacity: 0.3,
            header: "No Recent Accounts Found",
            subHeader: "You currently do not have followers",
            refreshData: null,
          )
        : listUserResults(model);
  }

  Widget listUserResults(UserFollowersViewModel model) {
    return ListUsers(
      refreshData: model.refreshUsers,
      userResults: model.userSearchResults.isEmpty ? model.userResults : model.userSearchResults,
      pageStorageKey: null,
      scrollController: model.scrollController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserFollowersViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => UserFollowersViewModel(),
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
