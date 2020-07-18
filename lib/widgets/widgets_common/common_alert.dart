import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webblen/services_general/services_user_options.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_custom_alert.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';

class FailureDialog extends StatelessWidget {
  final String header;
  final String body;

  FailureDialog({
    this.header,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return new CustomAlertDialog(
      content: Container(
        height: 230.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Container(
              child: Column(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.exclamationCircle,
                    color: Colors.red,
                    size: 30.0,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW700(header, 18, Colors.black, TextAlign.center),
                  ),
                ],
              ),
            ),
            // dialog centre
            SizedBox(
              height: 8.0,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW400(body, 16, Colors.black, TextAlign.center),
                  ),
                ],
              ),
            ),
            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Ok",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  final BuildContext context;

  LogoutDialog({
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 240.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Container(
              child: Column(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.red,
                    size: 30.0,
                  ),
                ],
              ),
            ),
            // dialog centre
            SizedBox(
              height: 8.0,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      "Are You Sure You Want to Logout?",
                      style: Fonts.alertDialogBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Logout",
                    textColor: Colors.white,
                    backgroundColor: Colors.red,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => UserOptionsService().signUserOut(context),
                  ),
                  CustomColorButton(
                    text: "Cancel",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateAvailableDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 8.0,
            ),
            Text(
              "Update Required",
              style: Fonts.alertDialogHeader,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      content: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.0,
        ),
        child: Text(
          "Please Update Your Current Version of Webblen to Continue",
          style: Fonts.alertDialogBody,
          textAlign: TextAlign.center,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Text(
              "Ok",
              style: Fonts.alertDialogAction,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String header;
  final String body;

  SuccessDialog({
    this.header,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        width: 260.0,
        height: 230.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // dialog top
            Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      header,
                      style: Fonts.alertDialogHeader,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // dialog centre
            SizedBox(
              height: 16.0,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      body,
                      style: Fonts.alertDialogBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 14.0,
            ),
            // ),
            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Ok",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashEventSuccessDialog extends StatelessWidget {
  final String messageA;
  final String messageB;
  final BuildContext successContext;

  FlashEventSuccessDialog({
    this.messageA,
    this.messageB,
    this.successContext,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        width: 260.0,
        height: 200.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      messageA,
                      style: Fonts.alertDialogHeader,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // dialog centre
            SizedBox(
              height: 16.0,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      messageB,
                      style: Fonts.alertDialogBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 14.0,
            ),
            // ),
            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Ok",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CancelActionDialog extends StatelessWidget {
  final String header;
  final String body;
  final VoidCallback cancelAction;

  CancelActionDialog({
    this.header,
    this.body,
    this.cancelAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 190.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW700(
                      header,
                      18.0,
                      Colors.black,
                      TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // dialog centre
            SizedBox(
              height: 16.0,
            ),
            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Yes",
                    textColor: Colors.white,
                    backgroundColor: FlatColors.webblenRed,
                    height: 45.0,
                    width: 200.0,
                    onPressed: cancelAction,
                  ),
                  CustomColorButton(
                    text: "Back",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CancelEventDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 245.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Container(
              child: Column(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.exclamationCircle,
                    color: Colors.red,
                    size: 30.0,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      "Cancel New Event?",
                      style: Fonts.alertDialogHeader,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // dialog centre
            SizedBox(
              height: 16.0,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      "All Progress Will Be Lost",
                      style: Fonts.alertDialogBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Cancel New Event",
                    textColor: Colors.white,
                    backgroundColor: FlatColors.webblenRed,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                      (Route<dynamic> route) => false,
                    ),
                  ),
                  CustomColorButton(
                    text: "Back",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventUploadSuccessDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        width: 260.0,
        height: 200.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      "Event Posted!",
                      style: Fonts.alertDialogHeader,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // dialog centre
            SizedBox(
              height: 16.0,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      "Interested Users Nearby Will be Notified",
                      style: Fonts.alertDialogBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // ),
            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Ok",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventOptionsDialog extends StatelessWidget {
  final VoidCallback viewAttendeesAction;
  final VoidCallback shareEventAction;
  final VoidCallback shareLinkAction;
  final VoidCallback editAction;
  final VoidCallback deleteEventAction;

  EventOptionsDialog({
    this.viewAttendeesAction,
    this.shareEventAction,
    this.shareLinkAction,
    this.editAction,
    this.deleteEventAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: editAction == null ? deleteEventAction == null ? viewAttendeesAction == null ? shareEventAction == null ? 150 : 180 : 220 : 280 : 310,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW700(
                      'Event Options',
                      24,
                      Colors.black,
                      TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  viewAttendeesAction != null
                      ? CustomColorIconButton(
                          icon: Icon(
                            FontAwesomeIcons.users,
                            color: Colors.black,
                            size: 16.0,
                          ),
                          text: "View Attendees",
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                          height: 45.0,
                          width: 200.0,
                          onPressed: viewAttendeesAction,
                        )
                      : Container(),
                  shareEventAction != null
                      ? CustomColorIconButton(
                          icon: Icon(
                            FontAwesomeIcons.share,
                            color: Colors.black,
                            size: 16.0,
                          ),
                          text: "Share Event",
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                          height: 45.0,
                          width: 200.0,
                          onPressed: shareEventAction,
                        )
                      : Container(),
                  shareLinkAction != null
                      ? CustomColorIconButton(
                          icon: Icon(
                            FontAwesomeIcons.link,
                            color: Colors.black,
                            size: 16.0,
                          ),
                          text: "Share Link",
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                          height: 45.0,
                          width: 200.0,
                          onPressed: shareLinkAction,
                        )
                      : Container(),
                  editAction != null
                      ? CustomColorIconButton(
                          icon: Icon(
                            FontAwesomeIcons.edit,
                            color: Colors.black,
                            size: 16.0,
                          ),
                          text: "Edit Event",
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                          height: 45.0,
                          width: 200.0,
                          onPressed: editAction)
                      : Container(),
                  deleteEventAction != null
                      ? CustomColorIconButton(
                          icon: Icon(
                            FontAwesomeIcons.trash,
                            color: Colors.white,
                            size: 16.0,
                          ),
                          text: "Delete Event",
                          textColor: Colors.white,
                          backgroundColor: Colors.red,
                          height: 45.0,
                          width: 200.0,
                          onPressed: deleteEventAction,
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoDialog extends StatelessWidget {
  final String header;
  final String body;

  InfoDialog({
    this.header,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        width: 260.0,
        height: 260.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // dialog top
            Container(
                child: Column(
              children: <Widget>[
                SizedBox(
                  height: 8.0,
                ),
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: CustomText(
                    context: context,
                    text: header,
                    textColor: Colors.black,
                    textAlign: TextAlign.center,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )),
            // dialog centre
            SizedBox(
              height: 8.0,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  CustomText(
                    context: context,
                    text: body,
                    textColor: Colors.black,
                    textAlign: TextAlign.center,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            // ),
            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Ok",
                    textColor: Colors.black,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionMessage extends StatelessWidget {
  final String messageHeader;
  final String messageA;
  final VoidCallback callback;

  ActionMessage({
    this.messageHeader,
    this.messageA,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 80.0,
      child: Column(
        children: <Widget>[
          Text(
            messageHeader,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: FlatColors.blackPearl,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return AlertDialog(
      title: Container(),
      content: content,
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        FlatButton(
          onPressed: () {
            callback();
          },
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Text(
              "Confirm",
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//***EVENT INFO
class AdditionalEventInfoDialog extends StatelessWidget {
  final int estimatedTurnout;
  final double eventCost;

  AdditionalEventInfoDialog({
    this.estimatedTurnout,
    this.eventCost,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        width: 260.0,
        height: 180.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Container(
              child: Column(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.users,
                    size: 30.0,
                    color: FlatColors.darkMountainGreen,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      "Turnout Info",
                      style: Fonts.alertDialogHeader,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // dialog centre
            SizedBox(
              height: 24.0,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.users,
                            size: 20.0,
                            color: FlatColors.blueGray,
                          ),
                          SizedBox(
                            width: 16.0,
                          ),
                          MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Text(
                              estimatedTurnout.toString(),
                              style: Fonts.alertDialogBody,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.dollarSign,
                            size: 20.0,
                            color: FlatColors.blueGray,
                          ),
                          SizedBox(
                            width: 2.0,
                          ),
                          MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: eventCost == null
                                ? Text(
                                    "Free",
                                    style: Fonts.alertDialogBody,
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    eventCost.toString(),
                                    style: Fonts.alertDialogBody,
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ),
            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Back",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//***EVENT CHECK IN
class EventCheckInDialog extends StatelessWidget {
  final String eventTitle;
  final VoidCallback confirmAction;

  EventCheckInDialog({
    this.eventTitle,
    this.confirmAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        width: 260.0,
        height: 200.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Container(
                child: Column(
              children: <Widget>[
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: Fonts().textW700(
                    "$eventTitle",
                    18.0,
                    FlatColors.darkGray,
                    TextAlign.center,
                  ),
                ),
              ],
            )),
            // dialog centre
            SizedBox(
              height: 8.0,
            ),
            // dialog bottom
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CustomColorButton(
                    text: "Check In",
                    textColor: FlatColors.darkGray,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: confirmAction,
                  ),
                  CustomColorButton(
                    text: "Cancel",
                    textColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String header;
  final String confirmActionTitle;
  final VoidCallback confirmAction;
  final VoidCallback cancelAction;

  ConfirmationDialog({
    this.header,
    this.confirmActionTitle,
    this.confirmAction,
    this.cancelAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        width: 260.0,
        height: 275.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.questionCircle,
                    size: 30.0,
                    color: FlatColors.darkGray,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Text(
                      header,
                      style: Fonts.alertDialogHeader,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  CustomColorButton(
                    text: confirmActionTitle,
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: confirmAction,
                  ),
                  CustomColorButton(
                    text: "Cancel",
                    textColor: FlatColors.clouds,
                    backgroundColor: Colors.red,
                    height: 45.0,
                    width: 200.0,
                    onPressed: cancelAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedConfirmationDialog extends StatelessWidget {
  final String header;
  final String body;
  final String confirmActionTitle;
  final VoidCallback confirmAction;
  final VoidCallback cancelAction;

  DetailedConfirmationDialog({
    this.header,
    this.body,
    this.confirmActionTitle,
    this.confirmAction,
    this.cancelAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        width: 260.0,
        height: 275.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Fonts().textW700(
                    header,
                    18.0,
                    FlatColors.darkGray,
                    TextAlign.center,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW500(
                      body,
                      16.0,
                      FlatColors.darkGray,
                      TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  CustomColorButton(
                    text: confirmActionTitle,
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: confirmAction,
                  ),
                  CustomColorButton(
                    text: "Cancel",
                    textColor: FlatColors.clouds,
                    backgroundColor: Colors.red,
                    height: 45.0,
                    width: 200.0,
                    onPressed: cancelAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityOptionsDialog extends StatelessWidget {
  final bool isMember;
  final String communityType;
  final VoidCallback viewMembersAction;
  final VoidCallback setComImageAction;
  final VoidCallback addAction;
  final VoidCallback inviteAction;
  final VoidCallback leaveAction;
  final VoidCallback joinAction;

  CommunityOptionsDialog({
    this.isMember,
    this.communityType,
    this.viewMembersAction,
    this.setComImageAction,
    this.inviteAction,
    this.addAction,
    this.leaveAction,
    this.joinAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: isMember ? 325.0 : 150.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isMember
                ? CustomColorIconButton(
                    icon: Icon(
                      FontAwesomeIcons.calendarPlus,
                      color: Colors.black,
                      size: 18.0,
                    ),
                    text: "Add Post/Event",
                    textColor: FlatColors.darkGray,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: addAction,
                  )
                : Container(),
            CustomColorIconButton(
              icon: Icon(
                FontAwesomeIcons.users,
                color: Colors.black,
                size: 18.0,
              ),
              text: "View Members",
              textColor: FlatColors.darkGray,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: viewMembersAction,
            ),
            isMember
                ? CustomColorIconButton(
                    icon: Icon(
                      FontAwesomeIcons.image,
                      color: Colors.black,
                      size: 18.0,
                    ),
                    text: "Set Community Pic",
                    textColor: FlatColors.darkGray,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: setComImageAction,
                  )
                : Container(),
            isMember
                ? CustomColorIconButton(
                    icon: Icon(
                      FontAwesomeIcons.userPlus,
                      color: Colors.black,
                      size: 18.0,
                    ),
                    text: "Invite",
                    textColor: FlatColors.darkGray,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: inviteAction,
                  )
                : Container(),
            isMember
                ? CustomColorButton(
                    text: "Leave Community",
                    textColor: Colors.white,
                    backgroundColor: FlatColors.webblenRed,
                    height: 45.0,
                    width: 200.0,
                    onPressed: leaveAction,
                  )
                : communityType == 'public'
                    ? CustomColorButton(
                        text: "Join Community",
                        textColor: Colors.white,
                        backgroundColor: FlatColors.darkMountainGreen,
                        height: 45.0,
                        width: 200.0,
                        onPressed: joinAction,
                      )
                    : Container(
                        child: Fonts().textW400(
                          "Invite Only",
                          14,
                          Colors.black54,
                          TextAlign.center,
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class UserDetailsOptionsDialog extends StatelessWidget {
  final String friendRequestStatus;
  final VoidCallback addFriendAction;
  final VoidCallback confirmRequestAction;
  final VoidCallback denyRequestAction;
  final VoidCallback messageUserAction;
  final VoidCallback removeFriendAction;
  final VoidCallback hideFromUserAction;
  final VoidCallback blockUserAction;

  UserDetailsOptionsDialog({
    this.addFriendAction,
    this.removeFriendAction,
    this.confirmRequestAction,
    this.denyRequestAction,
    this.hideFromUserAction,
    this.blockUserAction,
    this.friendRequestStatus,
    this.messageUserAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 200.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.cog,
                    size: 30.0,
                    color: FlatColors.londonSquare,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: friendRequestStatus == "receivedRequest"
                        ? Text(
                            "Pending Friend Request",
                            style: Fonts.alertDialogHeader,
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            "Options",
                            style: Fonts.alertDialogHeader,
                            textAlign: TextAlign.center,
                          ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  friendRequestStatus == "friends"
                      ? CustomColorButton(
                          text: "Message",
                          textColor: FlatColors.londonSquare,
                          backgroundColor: Colors.white,
                          height: 45.0,
                          width: 200.0,
                          onPressed: messageUserAction,
                        )
                      : Container(),
                  friendRequestStatus == "friends"
                      ? CustomColorButton(
                          text: "Remove Friend",
                          textColor: FlatColors.clouds,
                          backgroundColor: Colors.red,
                          height: 45.0,
                          width: 200.0,
                          onPressed: removeFriendAction,
                        )
                      : friendRequestStatus == "pending"
                          ? CustomColorButton(
                              text: "Request Pending",
                              textColor: FlatColors.londonSquare,
                              backgroundColor: Colors.white,
                              height: 45.0,
                              width: 200.0,
                              onPressed: null,
                            )
                          : friendRequestStatus == "receivedRequest"
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CustomColorButton(
                                      text: "Accept",
                                      textColor: Colors.white,
                                      backgroundColor: FlatColors.darkMountainGreen,
                                      height: 40.0,
                                      width: MediaQuery.of(context).size.width * 0.22,
                                      onPressed: confirmRequestAction,
                                    ),
                                    CustomColorButton(
                                      text: "Ignore",
                                      textColor: FlatColors.darkGray,
                                      backgroundColor: Colors.white,
                                      height: 40.0,
                                      width: MediaQuery.of(context).size.width * 0.22,
                                      onPressed: denyRequestAction,
                                    ),
                                  ],
                                )
                              : CustomColorButton(
                                  text: "Add Friend",
                                  textColor: FlatColors.londonSquare,
                                  backgroundColor: Colors.white,
                                  height: 45.0,
                                  width: 200.0,
                                  onPressed: addFriendAction,
                                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddImageDialog extends StatelessWidget {
  final VoidCallback imageFromCameraAction;
  final VoidCallback imageFromLibraryAction;

  AddImageDialog({
    this.imageFromCameraAction,
    this.imageFromLibraryAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 160.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
                child: Column(
              children: <Widget>[
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: Fonts().textW700(
                    'Add Image',
                    24,
                    Colors.black,
                    TextAlign.center,
                  ),
                ),
              ],
            )),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CustomColorIconButton(
                    icon: Icon(
                      FontAwesomeIcons.camera,
                      color: Colors.black,
                      size: 16.0,
                    ),
                    text: "Camera",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: imageFromCameraAction,
                  ),
                  CustomColorIconButton(
                    icon: Icon(
                      FontAwesomeIcons.images,
                      color: Colors.black,
                      size: 16.0,
                    ),
                    text: "Gallery",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: imageFromLibraryAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionSuccessDialog extends StatelessWidget {
  final String header;
  final String body;
  final VoidCallback action;

  ActionSuccessDialog({
    this.header,
    this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 160.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW700(
                      header,
                      18.0,
                      FlatColors.darkGray,
                      TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW500(
                      body,
                      14.0,
                      FlatColors.darkGray,
                      TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            CustomColorButton(
              text: "Ok",
              textColor: FlatColors.darkGray,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: action,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomActionDialog extends StatelessWidget {
  final String header;
  final String body;
  final String buttonText;
  final VoidCallback action;

  CustomActionDialog({
    this.header,
    this.body,
    this.buttonText,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 180.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW700(
                      header,
                      18.0,
                      FlatColors.darkGray,
                      TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW500(
                      body,
                      14.0,
                      FlatColors.darkGray,
                      TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            CustomColorButton(
              text: buttonText,
              textColor: FlatColors.darkGray,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: action,
            ),
          ],
        ),
      ),
    );
  }
}

class FormActionDialog extends StatelessWidget {
  final String header;
  final Widget formWidget;
  final VoidCallback action;

  FormActionDialog({
    this.header,
    this.formWidget,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 225.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                child: Column(children: <Widget>[
              MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0,
                ),
                child: Fonts().textW700(
                  header,
                  18.0,
                  FlatColors.darkGray,
                  TextAlign.center,
                ),
              ),
            ])),
            SizedBox(
              height: 8.0,
            ),
            formWidget,
            SizedBox(
              height: 8.0,
            ),
            CustomColorButton(
              text: "Submit",
              textColor: FlatColors.darkGray,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: action,
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 3.0,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 3.0,
              child: CustomLinearProgress(
                progressBarColor: FlatColors.webblenRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingCommunityDialog extends StatelessWidget {
  final String areaName;
  final String comName;

  LoadingCommunityDialog({
    this.areaName,
    this.comName,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 30.0,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Fonts().textW500(
              'Loading $areaName/$comName...',
              14.0,
              Colors.black,
              TextAlign.center,
            ),
            SizedBox(
              height: 8.0,
            ),
            Container(
              height: 3.0,
              child: CustomLinearProgress(
                progressBarColor: FlatColors.webblenRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountQRDialog extends StatelessWidget {
  final String username;
  final String uid;
  final VoidCallback scanAction;
  final VoidCallback scanForTicketsAction;

  AccountQRDialog({
    this.username,
    this.uid,
    this.scanAction,
    this.scanForTicketsAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: scanForTicketsAction == null ? 300.0 : 350.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 150.0,
                width: 150.0,
                child: QrImage(
                  data: 'addFriend.$uid-$username',
                  version: QrVersions.auto,
                  size: 150.0,
                  gapless: true,
                )),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
              child: Fonts().textW700(
                username,
                18.0,
                Colors.black,
                TextAlign.center,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            CustomColorIconButton(
              icon: Icon(FontAwesomeIcons.camera, color: Colors.black, size: 16.0),
              text: "Add Friend",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              height: 40.0,
              width: 200.0,
              onPressed: scanAction,
            ),
            scanForTicketsAction == null
                ? Container()
                : CustomColorIconButton(
                    icon: Icon(FontAwesomeIcons.ticketAlt, color: Colors.black, size: 16.0),
                    text: "Scan For Tickets",
                    textColor: Colors.black,
                    backgroundColor: Colors.white,
                    height: 40.0,
                    width: 200.0,
                    onPressed: scanForTicketsAction,
                  ),
            CustomColorButton(
              text: "Close",
              textColor: FlatColors.darkGray,
              backgroundColor: Colors.white,
              height: 40.0,
              width: 200.0,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannedAccountDialog extends StatelessWidget {
  final String username;
  final String uid;
  final VoidCallback addFriendAction;

  ScannedAccountDialog({
    this.username,
    this.uid,
    this.addFriendAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 275.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            UserProfilePicFromUID(
              uid: uid,
              size: 100.0,
            ),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
              child: Fonts().textW700(
                username,
                24.0,
                Colors.black,
                TextAlign.center,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            CustomColorButton(
              text: "Add Friend",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: addFriendAction,
            ),
            CustomColorButton(
              text: "Cancel",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarFilterDialog extends StatelessWidget {
  final String currentFilter;
  final VoidCallback changeFilterToAllEvents;
  final VoidCallback changeFilterToCreatedEvents;
  final VoidCallback changeFilterToSavedEvents;
  final VoidCallback changeFilterToReminders;

  CalendarFilterDialog({
    this.currentFilter,
    this.changeFilterToSavedEvents,
    this.changeFilterToAllEvents,
    this.changeFilterToCreatedEvents,
    this.changeFilterToReminders,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 275.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomColorButton(
                text: "All Events",
                textColor: currentFilter == "all" ? Colors.white : Colors.black,
                backgroundColor: currentFilter == "all" ? FlatColors.webblenRed : Colors.white,
                height: 45.0,
                width: 200.0,
                onPressed: () {
                  changeFilterToAllEvents();
                  Navigator.of(context).pop();
                }),
            CustomColorButton(
                text: "Saved Events",
                textColor: currentFilter == "saved" ? Colors.white : Colors.black,
                backgroundColor: currentFilter == "saved" ? FlatColors.webblenRed : Colors.white,
                height: 45.0,
                width: 200.0,
                onPressed: () {
                  changeFilterToSavedEvents();
                  Navigator.of(context).pop();
                }),
            CustomColorButton(
                text: "Created Events",
                textColor: currentFilter == "created" ? Colors.white : Colors.black,
                backgroundColor: currentFilter == "created" ? FlatColors.webblenRed : Colors.white,
                height: 45.0,
                width: 200.0,
                onPressed: () {
                  changeFilterToCreatedEvents();
                  Navigator.of(context).pop();
                }),
            CustomColorButton(
              text: "Reminders",
              textColor: currentFilter == "reminder" ? Colors.white : Colors.black,
              backgroundColor: currentFilter == "reminder" ? FlatColors.webblenRed : Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: () {
                changeFilterToReminders();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CreateEventReminderDialog extends StatelessWidget {
  final VoidCallback createEvent;
  final VoidCallback createReminder;

  CreateEventReminderDialog({
    this.createEvent,
    this.createReminder,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 175.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomColorButton(
              text: "Create Event",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: createEvent,
            ),
            CustomColorButton(
              text: "Create Reminder",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: createReminder,
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarEventOptionsDialog extends StatelessWidget {
  final VoidCallback editAction;
  final VoidCallback deleteAction;

  CalendarEventOptionsDialog({
    this.editAction,
    this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 175.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomColorButton(
              text: "Edit Reminder",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 200.0,
              onPressed: editAction,
            ),
            CustomColorButton(
              text: "Delete Reminder",
              textColor: Colors.white,
              backgroundColor: Colors.red,
              height: 45.0,
              width: 200.0,
              onPressed: deleteAction,
            ),
          ],
        ),
      ),
    );
  }
}

class FormDialog extends StatelessWidget {
  final Widget form;
  FormDialog({this.form});

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
        ),
        child: form,
      ),
    );
  }
}

class CheckExampleDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Container(
        height: 200.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
              child: Fonts().textW500(
                "You Can Find Your Routing & Account Number on a Bank Check",
                18.0,
                FlatColors.darkGray,
                TextAlign.center,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              child: Image.asset(
                "assets/images/check_example.png",
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
