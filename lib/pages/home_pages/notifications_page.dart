import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/firebase/services/notifications.dart';
import 'package:webblen/firebase_data/user_data.dart';
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
  final VoidCallback viewWalletAction;

  NotificationPage({
    this.currentUser,
    this.viewWalletAction,
  });

  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Widget buildNotificationsView() {
    return Container(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
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
          notifDocs = notifSnapshot.data.docs.toList();
          notifDocs.sort((notifDocA, notifDocB) => notifDocB.data()['notificationExpDate'].compareTo(notifDocA.data()['notificationExpDate']));
          return notifDocs.isEmpty
              ? buildEmptyListView("No Messages Found")
              : ListView(
                  padding: EdgeInsets.only(
                    top: 4.0,
                    bottom: 4.0,
                  ),
                  children: notifDocs.map((DocumentSnapshot notifDoc) {
                    WebblenNotification notif = WebblenNotification.fromMap(notifDoc.data());
                    if (notif.notificationSeen == false) {
                      WebblenNotificationDataService().updateNotificationStatus(notif.notificationKey);
                    }
                    return NotificationRow(
                      notification: notif,
                      notificationAction: notif.notificationType == "deposit" ? widget.viewWalletAction : () => notificationAction(notif),
                    );
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

  notificationAction(WebblenNotification notif) async {
    String notifType = notif.notificationType;
    if (notifType == "user") {
      ShowAlertDialogService().showLoadingDialog(context);
      WebblenUser user = await UserDataService().getUserByID(notif.notificationSender);
      Navigator.of(context).pop();
      PageTransitionService(
        context: context,
        currentUser: widget.currentUser,
        webblenUser: user,
      ).transitionToUserPage();
    } else if (notifType == "event") {
      PageTransitionService(
        context: context,
        currentUser: widget.currentUser,
        eventID: notif.notificationData,
      ).transitionToEventPage();
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
