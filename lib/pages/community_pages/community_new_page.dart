import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/firebase_data/auth.dart';
import 'package:webblen/firebase_data/webblen_notification_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets/widgets_common/common_flushbar.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_user/user_row.dart';

class CreateCommunityPage extends StatefulWidget {
  final String areaName;

  CreateCommunityPage({
    this.areaName,
  });

  @override
  State<StatefulWidget> createState() {
    return _CreateCommunityPageState();
  }
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  WebblenUser currentUser;
  bool isLoading = true;

  //Keys
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> page1FormKey;
  final page2FormKey = GlobalKey<FormState>();

  //Event
  Geoflutterfire geo = Geoflutterfire();
  double lat;
  double lon;
  Community newCommunity = Community();
  List<WebblenUser> searchResults = [];
  List<WebblenUser> friends = [];
  List invitedUsers = [];
  int pageIndex = 0;
  int communityTypeRadioVal = 0;
  bool isPrivate = false;

  //Paging
  PageController _pageController;
  void nextPage() {
    pageIndex += 1;
    setState(() {});
    _pageController.nextPage(
      duration: Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
    );
  }

  void previousPage() {
    pageIndex -= 1;
    setState(() {});
    _pageController.previousPage(
      duration: Duration(
        milliseconds: 600,
      ),
      curve: Curves.easeIn,
    );
  }

  Future<Null> initialize() async {
    BaseAuth().currentUser().then((uid) {
      Firestore.instance
          .collection("webblen_user")
          .document(uid)
          .get()
          .then((userDoc) {
        if (userDoc.exists) {
          UserDataService().getUserByID(uid).then((result) {
            currentUser = result;
            UserDataService()
                .getUsersFromList(currentUser.friends)
                .then((result) {
              friends = result;
              friends.sort(
                  (userA, userB) => userA.username.compareTo(userB.username));
              isLoading = false;
              setState(() {});
            });
          });
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/setup',
            (Route<dynamic> route) => false,
          );
        }
      });
    });
  }

  //Form Validations
  void validateCommunityName() {
    final form = page1FormKey.currentState;
    form.save();
    if (newCommunity.name == null || newCommunity.name.isEmpty) {
      AlertFlushbar(
        headerText: "Error",
        bodyText: "Event Title Cannot be Empty",
      ).showAlertFlushbar(context);
    } else {
      ShowAlertDialogService().showLoadingDialog(context);
      newCommunity.name.trim();
      newCommunity.name.replaceAll(
        RegExp(r"\s+\b|\b\s"),
        "",
      );
      newCommunity.name.replaceAll(
        "#",
        "",
      );
      newCommunity.name = '#' + newCommunity.name;
      CommunityDataService()
          .checkIfCommunityExists(
        widget.areaName,
        newCommunity.name,
      )
          .then((exists) {
        if (exists) {
          Navigator.of(context).pop();
          AlertFlushbar(
            headerText: "Error",
            bodyText:
                "The community ${newCommunity.name} already exists in this area",
          ).showAlertFlushbar(context);
        } else {
          Navigator.of(context).pop();
          nextPage();
        }
      });
    }
  }

  void handleRadioValueChanged(int value) {
    if (value == 2) {
      isPrivate = true;
    }
    communityTypeRadioVal = value;
    setState(() {});
  }

  String getRadioValue() {
    String val = 'public';
    if (communityTypeRadioVal == 1) {
      val = 'closed';
    } else if (communityTypeRadioVal == 2) {
      val = 'secret';
    }
    return val;
  }

  void validateAndSubmit() {
    if (invitedUsers.isEmpty) {
      AlertFlushbar(
        headerText: "Error",
        bodyText: "You must invite at least 2 others to create a community",
      ).showAlertFlushbar(context);
    } else {
      ShowAlertDialogService().showLoadingDialog(context);
      newCommunity.areaName = widget.areaName;
      newCommunity.lastActivityTimeInMilliseconds =
          DateTime.now().millisecondsSinceEpoch;
      newCommunity.followers = [currentUser.uid];
      newCommunity.memberIDs = [currentUser.uid];
      newCommunity.areaName = widget.areaName;
      newCommunity.isPrivate = isPrivate;
      newCommunity.activityCount = 0;
      newCommunity.communityType = getRadioValue();
      newCommunity.eventCount = 0;
      newCommunity.last100Events = [];
      newCommunity.postCount = 0;
      newCommunity.subtags = [];
      newCommunity.status = "pending";
      CommunityDataService()
          .createCommunity(
        newCommunity,
        widget.areaName,
        currentUser.uid,
      )
          .then((error) {
        if (error.isEmpty) {
          invitedUsers.forEach((uid) {
            WebblenNotificationDataService()
                .sendCommunityInviteNotif(
              currentUser.uid,
              widget.areaName,
              newCommunity.name,
              uid,
              "@${currentUser.username} invited you to join ${newCommunity.name}",
            )
                .then((error) {
              if (error.isEmpty) {
                Navigator.of(context).pop();
                ShowAlertDialogService().showActionSuccessDialog(
                    context,
                    "Community Created!",
                    "Your Community Will be Live After 2 Other Members join!",
                    () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ShowAlertDialogService().showFailureDialog(
                  context,
                  "There's good news and bad news...",
                  "You're community was created, but we had issues let your invites know. Please try inviting them again.",
                );
              }
            });
          });
        } else {
          Navigator.of(context).pop();
          ShowAlertDialogService().showFailureDialog(
            context,
            'Uh Oh',
            'There was an issue creating your community. Please try again.',
          );
        }
      });
      //Navigator.push(context, ScaleRoute(widget: ConfirmEventPage(newEvent: newEventPost, newEventImage: eventImage)));
    }
  }

  void initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        searchResults = friends;
      });
    } else {
      searchResults = friends
          .where(
            (user) => user.username.contains(
              value.toLowerCase(),
            ),
          )
          .toList();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    page1FormKey = GlobalKey<FormState>();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildCommunityNameField() {
      return Container(
        color: Colors.white,
        margin: EdgeInsets.only(
          left: 8.0,
          right: 8.0,
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: TextFormField(
            maxLengthEnforced: true,
            textCapitalization: TextCapitalization.none,
            cursorColor: FlatColors.darkGray,
            style: TextStyle(
              color: FlatColors.darkGray,
              fontSize: 24.0,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
            ),
            autofocus: false,
            textAlign: TextAlign.left,
            inputFormatters: [
              LengthLimitingTextInputFormatter(30),
              BlacklistingTextInputFormatter(
                RegExp(
                    "[\\-|\\ |\\#|\\[|\\]|\\%|\\^|\\*|\\+|\\=|\\_|\\~|\\<|\\>|\\,|\\@|\\(|\\)|\\'|\\{|\\}|\\.]"),
              ),
            ],
            onSaved: (value) => newCommunity.name = value.toLowerCase(),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter Community Name",
              hintStyle: TextStyle(
                color: Colors.black26,
              ),
              counterStyle: TextStyle(
                fontFamily: 'Nunito',
              ),
              contentPadding: EdgeInsets.fromLTRB(
                8.0,
                16.0,
                8.0,
                10.0,
              ),
            ),
          ),
        ),
      );
    }

    //**Title, Description, Dates, URLS
    final formPage1 = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Form(
          key: page1FormKey,
          child: ListView(
            children: <Widget>[
              _buildCommunityNameField(),
              Container(
                height: 4.0,
                width: MediaQuery.of(context).size.width,
              ),
              SizedBox(
                height: 16.0,
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 8.0,
                  left: 16.0,
                  right: 8.0,
                  bottom: 4.0,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Fonts().textW700(
                              'Public',
                              18.0,
                              FlatColors.darkGray,
                              TextAlign.left,
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: 260.0,
                          ),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Fonts().textW400(
                              "This community and its activities can be found by anyone. \nNew members are added by invite or after attending a certain number of your events.",
                              14.0,
                              FlatColors.darkGray,
                              TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Radio(
                          value: 0,
                          groupValue: communityTypeRadioVal,
                          onChanged: handleRadioValueChanged,
                          activeColor: FlatColors.webblenRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 8.0,
                  left: 16.0,
                  right: 8.0,
                  bottom: 4.0,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Fonts().textW700(
                              'Closed',
                              18.0,
                              FlatColors.darkGray,
                              TextAlign.left,
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: 260.0,
                          ),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Fonts().textW400(
                              "This community and its activities are hidden from discover pages. \nNew members are added by invite only.",
                              14.0,
                              FlatColors.darkGray,
                              TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Radio(
                          value: 1,
                          groupValue: communityTypeRadioVal,
                          onChanged: handleRadioValueChanged,
                          activeColor: FlatColors.webblenRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 8.0,
                  left: 16.0,
                  right: 8.0,
                  bottom: 16.0,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Fonts().textW700(
                              'Secret',
                              18.0,
                              FlatColors.darkGray,
                              TextAlign.left,
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: 260.0,
                          ),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Fonts().textW400(
                              "This community and its activities are COMPETELY hidden. New members are added by invite only. \n*NOT ELIGIBLE FOR WEBBLEN PAYOUTS.",
                              14.0,
                              FlatColors.darkGray,
                              TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Radio(
                          value: 2,
                          groupValue: communityTypeRadioVal,
                          onChanged: handleRadioValueChanged,
                          activeColor: FlatColors.webblenRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    //**Tags Page
    final formPage2 = Container(
      child: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          String friendUid = friends[index].uid;
          return UserRowInvite(
            user: friends[index],
            onTap: () {
              if (invitedUsers.contains(friendUid)) {
                invitedUsers.remove(friendUid);
              } else {
                invitedUsers.add(friendUid);
              }
              setState(() {});
            },
            didInvite: invitedUsers.contains(friends[index].uid),
          );
        },
      ),
    );

    return Scaffold(
      appBar: WebblenAppBar().pagingAppBar(
        context,
        "Create Community",
        pageIndex == 0 ? "Next" : "Finish",
        pageIndex == 0
            ? () => ShowAlertDialogService().showCancelDialog(
                    context, 'Cancel Create a New Community?', () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                })
            : this.previousPage,
        pageIndex == 1 ? this.validateAndSubmit : this.validateCommunityName,
      ),
      key: homeScaffoldKey,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [formPage1, formPage2],
      ),
    );
  }
}
