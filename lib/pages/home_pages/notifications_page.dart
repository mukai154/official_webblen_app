import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/firebase/services/notifications.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_notifications/notification_row.dart';

class NotificationPage extends StatefulWidget {
  final WebblenUser currentUser;

  NotificationPage({
    this.currentUser,
  });

  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<WebblenNotification> notifications = [];

  Future<void> getUserNotifications() {
    notifications = [];
  }

  Widget buildNotificationsView() {
    //UserDataService().updateMessageNotifications(widget.currentUser.uid);
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('user_notifications')
            .where(
              'uid',
              isEqualTo: widget.currentUser.uid,
            )
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> notifSnapshot) {
          List<DocumentSnapshot> notifDocs = [];
          if (!notifSnapshot.hasData)
            return LoadingScreen(
              context: context,
              loadingDescription: "Loading...",
            );
          notifDocs = notifSnapshot.data.documents.toList();
          notifDocs.sort((notifDocA, notifDocB) => notifDocB.data['notificationExpDate'].compareTo(notifDocA.data['notificationExpDate']));
          return notifDocs.isEmpty
              ? buildEmptyListView("No Messages Found")
              : ListView(
                  children: notifDocs.map((DocumentSnapshot notifDoc) {
                    WebblenNotification notif = WebblenNotification.fromMap(notifDoc.data);
                    if (notif.notificationSeen == false) {
                      WebblenNotificationDataService().updateNotificationStatus(notif.notificationKey);
                    }
                    Widget notifWidget;
                    if (notif.notificationType == "friendRequest") {
                      notifWidget = InviteRequestNotificationRow(
                        notification: notif,
                        notifAction: () => transitionToUserDetails(notif.notificationData),
                        confirmRequest: () => confirmFriendRequest(notif),
                        denyRequest: () => denyFriendRequest(notif),
                      );
                    } else if (notif.notificationType == "invite") {
                      notifWidget = InviteRequestNotificationRow(
                        notification: notif,
                        notifAction: null,
                        confirmRequest: () => confirmCommunityInvite(notif),
                        denyRequest: () => denyCommunityInvite(notif),
                      );
                    } else {
                      notifWidget = NotificationRow(
                        notification: notif,
                        notificationAction: () => notificationAction(notif),
                      );
                    }
                    return notifWidget;
                  }).toList(),
                );
        },
      ),
    );
  }

  Widget buildEmptyListView(String emptyCaption) {
    return Container(
      margin: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 70.0,
          ),
          Fonts().textW500(
            emptyCaption,
            18.0,
            Colors.black26,
            TextAlign.center,
          ),
        ],
      ),
    );
  }

  confirmFriendRequest(WebblenNotification notif) async {
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService()
        .acceptFriendRequest(
      widget.currentUser.uid,
      notif.notificationData,
      notif.notificationKey,
    )
        .then((success) {
      if (success) {
        notifications.remove(notif);
        Navigator.of(context).pop();
        setState(() {});
        ShowAlertDialogService().showSuccessDialog(
          context,
          "Friend Added!",
          "You and @" + notif.notificationSender + " are now friends",
        );
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          "There was an Issue!",
          "Please Try Again Later",
        );
      }
    });
  }

  confirmCommunityInvite(WebblenNotification notif) async {
    int stringIndex = notif.notificationData.indexOf(".");
    String areaName = notif.notificationData.substring(
      0,
      stringIndex,
    );
    String comName = notif.notificationData.substring(
      stringIndex + 1,
      notif.notificationData.length,
    );
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService()
        .acceptCommunityInvite(
      areaName,
      comName,
      widget.currentUser.uid,
      notif.notificationKey,
    )
        .then((success) {
      if (success) {
        setState(() {});
        Navigator.of(context).pop();
        ShowAlertDialogService().showSuccessDialog(
          context,
          "You've Joined $comName!",
          "You can find it within your communities",
        );
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          "There was an Issue!",
          "Please Try Again Later",
        );
      }
    });
  }

  denyFriendRequest(WebblenNotification notif) async {
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService()
        .denyFriendRequest(
      widget.currentUser.uid,
      notif.notificationData,
      notif.notificationKey,
    )
        .then((success) {
      if (success) {
        notifications.remove(notif);
        Navigator.of(context).pop();
        setState(() {});
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          "There was an Issue!",
          "Please Try Again Later",
        );
      }
    });
  }

  denyCommunityInvite(WebblenNotification notif) async {
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService().deleteNotification(notif.notificationKey);
    notifications.remove(notif);
    setState(() {});
    Navigator.of(context).pop();
  }

  transitionToUserDetails(String peerID) async {
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService().getUserByID(peerID).then((user) {
      Navigator.of(context).pop();
      PageTransitionService(
        context: context,
        currentUser: widget.currentUser,
        webblenUser: user,
      ).transitionToUserPage();
    });
  }

  notificationAction(WebblenNotification notif) async {
    String notifType = notif.notificationType;
    //      FirebaseNotificationsService().deleteNotification(notifKey);
    if (notifType == "deposit") {
      Navigator.pop(context, 3);
    }
  }

  @override
  void initState() {
    super.initState();
    //EventDataService().transferOldEventData();
    //FirebaseNotificationsService().addDataField("notificationExpDate", 1558743222341);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 70,
            margin: EdgeInsets.only(
              left: 16,
              top: 30,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  context: context,
                  text: "Messages",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w700,
                ),
//                GestureDetector(
//                  onTap: null,
//                  child: Icon(
//                    FontAwesomeIcons.plus,
//                    size: 20.0,
//                    color: Colors.black,
//                  ),
//                ),
              ],
            ),
          ),
          Expanded(
            child: buildNotificationsView(),
          ),
        ],
      ),
    );

//      Scaffold(
//      appBar: WebblenAppBar().basicAppBar(
//        'Notifications',
//        context,
//      ),
//      body: Container(
//        child: buildNotificationsView(),
//      ),
//    );
  }
}
