import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_user/user_row.dart';

class UserSearchPage extends StatefulWidget {
  final List userIDs;
  final WebblenUser currentUser;
  final String pageTitle;

  UserSearchPage({
    this.currentUser,
    this.userIDs,
    this.pageTitle,
  });

  @override
  _UserSearchPageState createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  CollectionReference userRef = Firestore.instance.collection("webblen_user");
  List<DocumentSnapshot> userDocResults = [];
  ScrollController scrollController = ScrollController();
  int prevIndex = 0;
  List<WebblenUser> users = [];
  bool isLoading = true;

  getUsers() async {
    widget.userIDs.forEach((uid) async {
      DocumentSnapshot snapshot = await userRef.document(uid).get();
      WebblenUser user = WebblenUser.fromMap(snapshot.data['d']);
      users.add(user);
      if (widget.userIDs.last == uid) {
        isLoading = false;
        setState(() {});
      }
    });
  }

  Future<void> refreshData() async {
    prevIndex = 0;
    users = [];
    getUsers();
  }

  void transitionToUserDetails(WebblenUser webblenUser) {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      currentUser: widget.currentUser,
      webblenUser: webblenUser,
    ).transitionToUserPage();
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar(widget.pageTitle, context),
      body: isLoading
          ? LoadingScreen(
              context: context,
              loadingDescription: 'Loading Users...',
            )
          : ListView.builder(
              controller: scrollController,
              itemCount: users.length,
              itemBuilder: (context, i) {
                bool isFollowingUser = false;
                if (users[i].friends != null && users[i].friends.contains(widget.currentUser.uid)) {
                  isFollowingUser = true;
                }
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: UserRow(
                    user: users[i],
                    transitionToUserDetails: () => transitionToUserDetails(users[i]),
                    sendUserFriendRequest: null, //() => sendFriendRequest(searchResults[i]),
                  ),
                );
              },
            ),
    );
  }
}
