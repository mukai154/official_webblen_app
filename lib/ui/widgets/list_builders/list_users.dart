import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/user/user_block/user_block_widget.dart';

class ListUsers extends StatelessWidget {
  final List userResults;
  final VoidCallback refreshData;
  final PageStorageKey pageStorageKey;
  final ScrollController scrollController;
  ListUsers({@required this.refreshData, @required this.userResults, @required this.pageStorageKey, @required this.scrollController});

  Widget listUsers() {
    return RefreshIndicator(
      onRefresh: refreshData,
      backgroundColor: appBackgroundColor(),
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        key: pageStorageKey,
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: userResults.length,
        itemBuilder: (context, index) {
          WebblenUser user;
          bool displayBottomBorder = true;

          ///GET USER OBJECT
          if (userResults[index] is Map) {
            user = WebblenUser.fromMap(userResults[index]);
          } else if (userResults[index] is DocumentSnapshot) {
            user = WebblenUser.fromMap(userResults[index].data());
          } else {
            user = userResults[index];
          }

          ///DISPLAY BOTTOM BORDER
          if (userResults.last == userResults[index]) {
            displayBottomBorder = false;
          }
          return UserBlockWidget(
            user: user,
            displayBottomBorder: displayBottomBorder,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight(context),
      color: appBackgroundColor(),
      child: listUsers(),
    );
  }
}
