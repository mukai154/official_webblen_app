import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_user/user_row.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/firebase_data/webblen_notification_data.dart';

class EventAttendeesPage extends StatefulWidget {

  final String eventKey;
  final WebblenUser currentUser;
  EventAttendeesPage({this.eventKey, this.currentUser});

  @override
  _EventAttendeesPageState createState() => _EventAttendeesPageState();
}

class _EventAttendeesPageState extends State<EventAttendeesPage> {

  List<WebblenUser> eventAttendees = [];
  bool isLoading = true;
  final ScrollController scrollController = new ScrollController();


  void transitionToUserDetails(WebblenUser webblenUser){
    PageTransitionService(context: context, currentUser: widget.currentUser, webblenUser: webblenUser).transitionToUserDetailsPage();
  }

  void transitionToSearchPage(){
    List<String> attendeeIDs = [];
    eventAttendees.forEach((attendee){
      attendeeIDs.add(attendee.uid);
    });
    PageTransitionService(context: context, userIDs: attendeeIDs, currentUser: widget.currentUser, viewingMembersOrAttendees: true).transitionToUserSearchPage();
  }

  void sendFriendRequest(WebblenUser peerUser) async {
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService().checkFriendStatus(widget.currentUser.uid, peerUser.uid).then((friendStatus){
      if (friendStatus == "pending"){
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "Request Pending", "You already have a pending friend request");
      } else {
        WebblenNotificationDataService().sendFriendRequest(widget.currentUser.uid, widget.currentUser.username, peerUser.uid).then((requestStatus){
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
    EventDataService().getEventAttendees(widget.eventKey).then((attendees){
      if (attendees != null && attendees.isNotEmpty){
        eventAttendees = attendees;
        isLoading = false;
        setState(() {});
      } else {
        isLoading = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: WebblenAppBar().actionAppBar(
          'Event Attendees',
          IconButton(
            icon: Icon(FontAwesomeIcons.search, color: FlatColors.darkGray, size: 18.0),
            onPressed: () => transitionToSearchPage(),
          ),
        ),
        body: isLoading ? LoadingScreen(context: context, loadingDescription: 'Loading Attendees')
          : ListView.builder(
            itemBuilder: (context, index){
              return UserRow(
                user: eventAttendees[index],
                isFriendsWithUser: widget.currentUser.friends.contains(eventAttendees[index].uid),
                sendUserFriendRequest: () => sendFriendRequest(eventAttendees[index]),
                transitionToUserDetails: () => transitionToUserDetails(eventAttendees[index]),
              );
            },
            itemCount: eventAttendees.length,
            controller: scrollController,
        )
    );
  }
}