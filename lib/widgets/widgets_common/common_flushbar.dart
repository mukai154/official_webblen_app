import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';

class AlertFlushbar {
  final String headerText;
  final String bodyText;
  final String notificationType;
  final String uid;
  final double userPoints;

  AlertFlushbar({
    this.headerText,
    this.bodyText,
    this.notificationType,
    this.uid,
    this.userPoints,
  });

  transitionToWalletPage(BuildContext context, String uid) {
    PageTransitionService(
      context: context,
      uid: uid,
    ).transitionToWalletPage();
  }

  transitionToFriendsPage(BuildContext context, String uid) {
    PageTransitionService(
      context: context,
      uid: uid,
    ).transitionToFriendsPage();
  }

  transitionToCheckInPage(BuildContext context) {
    PageTransitionService(
      context: context,
    ).transitionToCheckInPage();
  }

  Widget notificationIcon(String notificationType) {
    Icon notifIcon;
    if (notificationType == 'flashEvent') {
      notifIcon = Icon(
        FontAwesomeIcons.bolt,
        color: FlatColors.webblenRed,
      );
    } else if (notificationType == 'userMessage') {
      notifIcon = Icon(
        FontAwesomeIcons.envelope,
        color: FlatColors.electronBlue,
      );
    } else if (notificationType == 'newCommunityBuilder') {
      notifIcon = Icon(
        FontAwesomeIcons.hammer,
        color: FlatColors.casandoraYellow,
      );
    } else if (notificationType == 'revokedCommunityBuilder') {
      notifIcon = Icon(
        FontAwesomeIcons.ban,
        color: Colors.red,
      );
    } else if (notificationType == 'friendRequest') {
      notifIcon = Icon(
        FontAwesomeIcons.userFriends,
        color: FlatColors.electronBlue,
      );
    } else if (notificationType == 'eventPoints') {
      notifIcon = Icon(
        FontAwesomeIcons.solidStar,
        color: FlatColors.casandoraYellow,
      );
    }
    return notifIcon;
  }

  Widget notificationButton(String notificationType, BuildContext context) {
    FlatButton notifButton;
    double textSize = MediaQuery.of(context).size.width * 0.04;
    if (notificationType == 'flashEvent') {
      notifButton = FlatButton(
        onPressed: transitionToCheckInPage(context),
        child: Fonts().textW500(
          "View",
          textSize,
          FlatColors.webblenRed,
          TextAlign.right,
        ),
      );
    } else if (notificationType == 'userMessage') {
      notifButton = FlatButton(
        onPressed: null,
        child: Fonts().textW500(
          "View",
          textSize,
          FlatColors.electronBlue,
          TextAlign.right,
        ),
      );
    } else if (notificationType == 'newCommunityBuilder') {
      notifButton = FlatButton(
        onPressed: null,
        child: Fonts().textW500(
          "Learn More",
          textSize,
          FlatColors.casandoraYellow,
          TextAlign.right,
        ),
      );
    } else if (notificationType == 'revokedCommunityBuilder') {
      notifButton = FlatButton(
        onPressed: null,
        child: Fonts().textW500(
          "See Why",
          textSize,
          Colors.red,
          TextAlign.right,
        ),
      );
    } else if (notificationType == 'friendRequest') {
      notifButton = FlatButton(
        onPressed: null,
        child: Fonts().textW500(
          "View",
          textSize,
          FlatColors.electronBlue,
          TextAlign.right,
        ),
      );
    } else if (notificationType == 'eventPoints') {
      notifButton = FlatButton(
        onPressed: () => ShowAlertDialogService().showInfoDialog(
          context,
          "test",
          "test",
        ),
        child: Fonts().textW500(
          "View Wallet",
          textSize,
          FlatColors.casandoraYellow,
          TextAlign.right,
        ),
      );
    }
    return notifButton;
  }

  void showAlertFlushbar(BuildContext context) {
    Flushbar flushbar = Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        titleText: Fonts().textW700(
          headerText,
          18.0,
          FlatColors.webblenRed,
          TextAlign.left,
        ),
        messageText: Fonts().textW500(
          bodyText,
          16.0,
          FlatColors.darkGray,
          TextAlign.left,
        ),
        reverseAnimationCurve: Curves.decelerate,
        forwardAnimationCurve: Curves.elasticOut,
        backgroundColor: FlatColors.iosOffWhite,
        icon: Icon(
          FontAwesomeIcons.exclamationTriangle,
          color: Colors.red,
        ),
//      shadowColor: FlatColors.darkGray,
        duration: Duration(seconds: 3));
    flushbar.show(context);
  }

  void showNotificationFlushBar(BuildContext context) {
    Flushbar flushbar = Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      titleText: Fonts().textW700(
        headerText,
        18,
        FlatColors.blackPearl,
        TextAlign.left,
      ),
      messageText: Fonts().textW500(
        bodyText,
        16,
        FlatColors.londonSquare,
        TextAlign.left,
      ),
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeIn,
      backgroundColor: FlatColors.iosOffWhite,
      icon: notificationIcon(
        notificationType,
      ),
      //mainButton: notificationButton(notificationType, context),
      duration: Duration(
        seconds: 7,
      ),
    );
    flushbar.show(context);
  }
}
