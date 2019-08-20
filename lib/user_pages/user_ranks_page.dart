import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_user/user_row.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'dart:async';
import 'package:webblen/firebase_data/auth.dart';
import 'package:webblen/widgets_data_streams/stream_user_data.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/firebase_data/webblen_notification_data.dart';

class UserRanksPage extends StatefulWidget {

  final String simLocation;
  final double simLat;
  final double simLon;
  UserRanksPage({this.simLocation, this.simLat, this.simLon});

  @override
  _UserRanksPageState createState() => _UserRanksPageState();
}

class _UserRanksPageState extends State<UserRanksPage> {

  String uid;
  WebblenUser currentUser;
  StreamSubscription userStream;
  double currentLat;
  double currentLon;
  List<WebblenUser> nearbyUsers = [];
  bool hasLocation = false;
  bool isLoading = true;

  Future<Null> initialize() async {
    BaseAuth().currentUser().then((val) {
      uid = val;
      Firestore.instance.collection("users").document(uid).get().then((userDoc){
        if (userDoc.exists) {
          StreamUserData.getUserStream(uid, getUser).then((StreamSubscription<DocumentSnapshot> s){
            userStream = s;
          });
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/setup', (Route<dynamic> route) => false);
        }
      });

    });
  }

  getUser(WebblenUser user){
    currentUser = user;
    if (currentUser != null){
      loadLocation();
    }
  }

  Future<Null> loadLocation() async {
    if (widget.simLocation != null){
      currentLat = widget.simLat;
      currentLon = widget.simLon;
      hasLocation = true;
      UserDataService().getNearbyUsers(currentLat, currentLon).then((users){
        nearbyUsers = users;
        nearbyUsers.sort((userA, userB) => userB.eventHistory.length.compareTo(userA.eventHistory.length));
        isLoading = false;
        setState(() {});
      });
    } else {
      LocationService().getCurrentLocation(context).then((location){
        if (this.mounted){
          if (location != null){
            hasLocation = true;
            currentLat = location.latitude;
            currentLon = location.longitude;
            UserDataService().getNearbyUsers(currentLat, currentLon).then((users){
              nearbyUsers = users;
              nearbyUsers.sort((userA, userB) => userB.eventHistory.length.compareTo(userA.eventHistory.length));
              isLoading = false;
              setState(() {});
            });
          }
        }
      });
    }
  }

  Widget noUsersFoundWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color(0xFFF9F9F9),
      child: new Column(
        children: <Widget>[
          SizedBox(height: 160.0),
          new Container(
            height: 85.0,
            width: 85.0,
            child: new Image.asset("assets/images/sleepy.png", fit: BoxFit.scaleDown),
          ),
          SizedBox(height: 16.0),
          Fonts().textW700("There's nobody around...", 24.0, FlatColors.darkGray, TextAlign.center),
          //new Text("No Nearby Users Found", style: Fonts.noEventsFont, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void sendFriendRequest(WebblenUser peerUser) async {
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService().checkFriendStatus(currentUser.uid, peerUser.uid).then((friendStatus){
      if (friendStatus == "pending"){
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "Request Pending", "You already have a pending friend request");
      } else {
        WebblenNotificationDataService().sendFriendRequest(currentUser.uid, peerUser.uid, currentUser.username).then((error){
          Navigator.of(context).pop();
          if (error.isEmpty){
            ShowAlertDialogService().showSuccessDialog(context, "Friend Request Sent!",  "@" + peerUser.username + " Will Need to Confirm Your Request");
          } else {
            ShowAlertDialogService().showFailureDialog(context, "Request Failed", error);
          }
        });
      }
    });
  }


  @override
  void initState() {
    super.initState();
    initialize();
  }


  @override
  Widget build(BuildContext context) {


    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = isLoading ? null : geo.point(latitude: currentLat, longitude: currentLon);
    CollectionReference userRef = Firestore.instance.collection("users");

    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
          'People Nearby',
          IconButton(
            icon: Icon(FontAwesomeIcons.search, color: FlatColors.darkGray, size: 18.0),
            onPressed: () => PageTransitionService(context: context, usersList: nearbyUsers, currentUser: currentUser, viewingMembersOrAttendees: false).transitionToUserSearchPage(),
          ),
      ),
      body: isLoading
        ? LoadingScreen(context: context, loadingDescription: "")
          : hasLocation
          ? Container(
              color: FlatColors.clouds,
              child: ListView.builder(
                itemBuilder: (context, index){
                  return UserRow(
                    user: nearbyUsers[index],
                    isFriendsWithUser: currentUser.friends.contains(nearbyUsers[index].uid),
                    sendUserFriendRequest: () => sendFriendRequest(nearbyUsers[index]),
                    transitionToUserDetails: () => PageTransitionService(context: context, currentUser: currentUser, webblenUser: nearbyUsers[index]).transitionToUserDetailsPage(),
                  );
                },
                itemCount: nearbyUsers.length,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Fonts().textW400("Unable to Access Location", 18.0, FlatColors.darkGray, TextAlign.center),
                CustomColorButton(
                  text: "Try Again",
                  textColor: Colors.white,
                  backgroundColor: FlatColors.webblenRed,
                  height: 45.0,
                  width: 200,
                  onPressed: () => loadLocation(),
                )
              ],
            ),
    );
  }
}