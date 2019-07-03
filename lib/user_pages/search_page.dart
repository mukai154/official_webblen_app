import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_user/user_row.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/firebase_services/user_data.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/firebase_services/community_data.dart';
import 'package:webblen/firebase_services/event_data.dart';
import 'package:webblen/widgets_community/community_row.dart';
import 'package:webblen/widgets_event/event_row.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/services_general/services_show_alert.dart';


class SearchPage extends StatefulWidget {

  final WebblenUser currentUser;
  final String areaName;
  SearchPage({this.currentUser, this.areaName});

  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {


  final formKey = new GlobalKey<FormState>();
  bool isSearching = false;
  String searchVal;
  List<Event> eventResults = [];
  List<WebblenUser> userResults = [];
  List<Community> communityResults = [];
  String resultType;
  bool searchPerformed = false;

  newSearch(){
    setState(() {
      searchPerformed = false;
      resultType = null;
    });
  }

  resetResults(){
    setState(() {
      isSearching = true;
      eventResults = [];
      userResults = [];
      communityResults = [];
      searchPerformed = true;
    });
    final form = formKey.currentState;
    form.save();
  }

  searchEvents() async {
    resetResults();
    EventDataService().searchForEventByName(searchVal, widget.areaName).then((result1){
      eventResults.addAll(result1);
      EventDataService().searchForEventByTag(searchVal, widget.areaName).then((result2){
        eventResults.addAll(result2);
        setState(() {
          isSearching = false;
          resultType = 'events';
        });
      });
    });
  }

  searchUsers() async {
    resetResults();
    UserDataService().searchForUserByName(searchVal, widget.areaName).then((result2){
      userResults.addAll(result2);
      setState(() {
        isSearching = false;
        resultType = 'users';
      });
    });
  }

  searchCommunities() async {
    resetResults();
    await CommunityDataService().searchForCommunityByName(searchVal, widget.areaName).then((result1){
      communityResults.addAll(result1);
      CommunityDataService().searchForCommmunityByTag(searchVal, widget.areaName).then((result2){
        communityResults.addAll(result2);
        setState(() {
          isSearching = false;
          resultType = 'communities';
        });
      });
    });
  }

  void transitionToUserDetails(WebblenUser webblenUser){
    Navigator.of(context).pop();
    PageTransitionService(context: context, currentUser: widget.currentUser, webblenUser: webblenUser).transitionToUserDetailsPage();
  }
  void transitionToEventDetails(Event event){
    Navigator.of(context).pop();
    PageTransitionService(context: context, currentUser: widget.currentUser, event: event, eventIsLive: false).transitionToEventPage();
  }
  void transitionToCommunityPage(Community community){
    Navigator.of(context).pop();
    PageTransitionService(context: context, currentUser: widget.currentUser, community: community, areaName: widget.areaName).transitionToCommunityProfilePage();
  }

  void sendFriendRequest(WebblenUser peerUser) async {
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService().checkFriendStatus(widget.currentUser.uid, peerUser.uid).then((friendStatus){
      if (friendStatus == "pending"){
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "Request Pending", "You already have a pending friend request");
      } else {
        UserDataService().addFriend(widget.currentUser.uid, widget.currentUser.username, peerUser.uid).then((requestStatus){
          Navigator.of(context).pop();
          if (requestStatus == "success"){
            ShowAlertDialogService().showSuccessDialog(context, "Friend Request Sent!",  "@" + peerUser.username + " Will Need to Confirm Your Request");
          } else {
            ShowAlertDialogService().showFailureDialog(context, "Request Failed", requestStatus);
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget _buildSearchField(){
      return new Container(
        margin: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: new TextFormField(
          maxLengthEnforced: true,
          textCapitalization: TextCapitalization.none,
          cursorColor: FlatColors.darkGray,
          style: TextStyle(color: FlatColors.darkGray, fontSize: 30.0, fontFamily: 'Nunito', fontWeight: FontWeight.w800),
          autofocus: false,
          textAlign: TextAlign.center,
          onSaved: (value) => searchVal = value.toLowerCase().trim(),
          decoration: InputDecoration(
            hintText: "Search",
            counterStyle: TextStyle(fontFamily: 'Nunito'),
            contentPadding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
          ),
        ),
      );
    }

    Widget resultsWidget(){
      Widget result;
      if (resultType == null || resultType.isEmpty){
        result = Column(
          children: <Widget>[
            Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: _buildSearchField(),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CustomColorButton(
                  text: "Users",
                  textColor: FlatColors.darkGray,
                  backgroundColor: Colors.white,
                  onPressed: () => searchUsers(),
                  width: 110.0,
                  hPadding: 4.0,
                ),
                CustomColorButton(
                  text: "Communities",
                  textColor: FlatColors.darkGray,
                  backgroundColor: Colors.white,
                  onPressed: () => searchCommunities(),
                  width: 110.0,
                  hPadding: 4.0,
                ),
                CustomColorButton(
                  text: "Events",
                  textColor: FlatColors.darkGray,
                  backgroundColor: Colors.white,
                  onPressed: () => searchEvents(),
                  width: 110.0,
                  hPadding: 4.0,
                ),
              ],
            )
          ],
        );
      } else if (resultType == "users"){
        result = userResults.isEmpty
            ? Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Fonts().textW400('Nobody found for "@$searchVal"', 18.0, FlatColors.darkGray, TextAlign.center),
                  ],
                )
              )
            : Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
              child: ListView.builder(
                  itemCount: userResults.length,
                  itemBuilder: (BuildContext context, int index){
                    return UserRow(
                        user: userResults[index],
                        transitionToUserDetails: () => transitionToUserDetails(userResults[index]),
                        sendUserFriendRequest: () => sendFriendRequest(userResults[index]),
                        isFriendsWithUser: false
                    );
                  }
              ),
        );
      } else if (resultType == "events"){
        result = eventResults.isEmpty
            ? Padding(
          padding: EdgeInsets.only(top: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Fonts().textW400('No events tagged "$searchVal" found nearby', 16.0, FlatColors.darkGray, TextAlign.center),
            ],
          )
        )
            : Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
              child: ListView.builder(
                  itemCount: eventResults.length,
                  itemBuilder: (BuildContext context, int index){
                    return ComEventRow(
                        event: eventResults[index],
                        showCommunity: true,
                        currentUser: widget.currentUser,
                        eventPostAction: () => transitionToEventDetails(eventResults[index])
                    );
                  }
              ),
        );
      } else if (resultType == "communities"){
        result = communityResults.isEmpty
            ? Padding(
          padding: EdgeInsets.only(top: 32.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Fonts().textW400('No community named "#$searchVal" found nearby', 16.0, FlatColors.darkGray, TextAlign.center),
              ],
            )
        )
            : Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
              child: ListView.builder(
                  itemCount: communityResults.length,
                  itemBuilder: (BuildContext context, int index){
                    return CommunityRow(
                        community: communityResults[index],
                        onClickAction: () => transitionToCommunityPage(communityResults[index]),
                        showAreaName: false
                    );
                  }
              ),
            );
      }
      return result;
    }

    return  Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Fonts().textW700('Search', 24.0, FlatColors.darkGray, TextAlign.center),
        backgroundColor: Color(0xFFF9F9F9),
        brightness: Brightness.light,
        leading: BackButton(color: Colors.black45),
        actions: <Widget>[
          searchPerformed
              ? GestureDetector(
                  onTap: () => newSearch(),
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.0, right: 8.0),
                    child: Fonts().textW500('New Search', 18.0, FlatColors.darkGray, TextAlign.center),
                  ),
                )
              : Container()
        ],
      ),
      body: isSearching
          ? LoadingScreen(context: context, loadingDescription: 'Searching...')
          : resultsWidget()
    );
  }
}
