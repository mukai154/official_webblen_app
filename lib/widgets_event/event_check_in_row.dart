import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'dart:async';
import 'package:webblen/widgets_common/common_alert.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/utils/time_calc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/create_notification.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/models/event.dart';

class NearbyEventCheckInRow extends StatefulWidget {

  final Event event;
  final String uid;
  final VoidCallback viewEventAction;
  NearbyEventCheckInRow({this.uid, this.event, this.viewEventAction});

  @override
  _NearbyEventCheckInRowState createState() => _NearbyEventCheckInRowState();
}

class _NearbyEventCheckInRowState extends State<NearbyEventCheckInRow> {


  bool isLoading = false;

  Future<bool> actionMessage(BuildContext context, String eventTitle, VoidCallback callback) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) { return EventCheckInDialog(eventTitle: eventTitle, confirmAction: callback);});
  }

  void userCheckInAction() async {
    String availableCheckInTime = await UserDataService().eventCheckInStatus(widget.uid);
    if (availableCheckInTime.isEmpty){
      checkIntoEvent();
    } else {
      ShowAlertDialogService().showFailureDialog(context, "You've Recently Checked In at Another Event", 'Next Available Time: $availableCheckInTime');
    }
  }


  void checkIntoEvent() async {
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService().updateEventCheckIn(widget.uid, widget.event).then((error){
      Navigator.of(context).pop();
      //widget.eventPost.attendees.add(widget.uid);
      CreateNotification().createTimedNotification(
          101,
          DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
          'Cooldown Complete!',
          'You can now check into another event',
          null
      );
    });
  }

  void checkoutOfEvent() async {
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService().checkoutOfEvent(widget.uid, widget.event).then((error){
      Navigator.of(context).pop();
      if (error.isEmpty){
        CreateNotification().deleteTimedNotification(101);
      } else {
        ShowAlertDialogService().showFailureDialog(context, "Uh Oh!", 'There was an issue checking out. Please Try Again');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List attendanceCount = widget.event.attendees;
    String endTime = TimeCalc().showTimeRemaining(widget.event.endDateInMilliseconds);
    String estimatedPayout =  (widget.event.eventPayout.toDouble()).toStringAsFixed(2);
    return GestureDetector(
      onTap: widget.viewEventAction,
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          width: MediaQuery.of(context).size.width - 16,
          height: MediaQuery.of(context).size.width - 16,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(widget.event.imageURL),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 8.0),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0),
                  Padding(
                    padding: EdgeInsets.only(right: 8.0, top: 4.0, bottom: 8.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(24.0),
                      color: FlatColors.textFieldGray,
                      child: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Fonts().textW500('Ends in $endTime', 12.0, Colors.black87, TextAlign.center)
                      ),
                    ),
                  )
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, FlatColors.transparent],
                      begin: Alignment(0.0, 1.0),
                      end: Alignment(0.0, -1.0),
                    ),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25.0), bottomRight: Radius.circular(25.0))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Fonts().textW700('${widget.event.title}', 26.0, Colors.white, TextAlign.left),

                    ),
                    Row(
                      children: [
                        SizedBox(width: 16.0),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: FlatColors.darkMountainGreen,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          child: Row(
                            children: [
                              attendanceCount == null || attendanceCount.isEmpty
                                  ? Fonts().textW500('0 Check Ins', 14.0, Colors.white, TextAlign.center)
                                  : Fonts().textW500(
                                  attendanceCount.length == 1 ? '${attendanceCount.length} Check Ins' : '${attendanceCount.length} Check Ins',
                                  14.0, Colors.white,
                                  TextAlign.center
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        CustomColorButton(
                          text: widget.event.attendees.contains(widget.uid) ? 'Check Out' : 'Check In',
                          textColor: widget.event.attendees.contains(widget.uid) ? Colors.white : FlatColors.darkGray,
                          backgroundColor: widget.event.attendees.contains(widget.uid) ? Colors.redAccent : Colors.white,
                          height: 45.0,
                          width: 100.0,
                          hPadding: 8.0,
                          vPadding: 0.0,
                          onPressed: widget.event.attendees.contains(widget.uid) ? () => checkoutOfEvent() : () => userCheckInAction(),
                        ),
                        SizedBox(width: 8.0),
                      ],
                    ),
                    SizedBox(height: 16.0)
                  ],
                ),
              ),

            ],
          )
      ),
    );
//      GestureDetector(
//        onTap: widget.viewEventAction,
//        child: Container(
//          decoration: BoxDecoration(
//              color: Colors.white,
//              borderRadius: BorderRadius.all(Radius.circular(12.0)),
//              boxShadow: ([
//                BoxShadow(
//                  color: Colors.black12,
//                  blurRadius: 1.8,
//                  spreadRadius: 0.5,
//                  offset: Offset(0.0, 3.0),
//                ),
//              ])
//          ),
//          child: Column(
//            children: <Widget>[
//              Row(
//                children: <Widget>[
//                  Padding(
//                    padding: EdgeInsets.only(left: 8.0, top: 8.0, right: 4.0),
//                    child: Fonts().textW700(widget.event.title, 18.0, FlatColors.darkGray, TextAlign.start),
//                  ),
//                ],
//              ),
//              Row(
//                children: <Widget>[
//                  Padding(
//                    padding: EdgeInsets.only(left: 6.0),
//                    child: Material(
//                      borderRadius: BorderRadius.circular(8.0),
//                      color: Colors.black12,
//                      child: Padding(
//                          padding: EdgeInsets.all(4.0),
//                          child: Fonts().textW500('Ends in $endTime', 12.0, Colors.black87, TextAlign.center)
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//              Container(
//                height: 280.0,
//                child: CachedNetworkImage(
//                  imageUrl: widget.event.imageURL,
//                  placeholder: (context, url) => Center(child: CustomLinearProgress(progressBarColor: FlatColors.webblenRed)),
//                  errorWidget: (context, url, error) => new Icon(Icons.error),
//                ),
//              ),
//              Row(
//                crossAxisAlignment: CrossAxisAlignment.start ,
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Padding(
//                        padding: EdgeInsets.only(left: 8.0),
//                        child: Material(
//                          borderRadius: BorderRadius.circular(24.0),
//                          color: FlatColors.greenTeal,
//                          child: Padding(
//                            padding: EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
//                            child: Row(
//                              children: <Widget>[
//                                SizedBox(width: 4.0),
//                                Fonts().textW700('Payout Pool: ', 14.0, Colors.white, TextAlign.left),
//                                Image.asset("assets/images/transparent_logo_xxsmall.png", height: 20.0, width: 20.0),
//                                SizedBox(width: 4.0),
//                                Fonts().textW700('$estimatedPayout', 14.0, Colors.white, TextAlign.center)
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
//                      Padding(
//                        padding: EdgeInsets.only(top: 2.0, left: 16.0, bottom: 8.0),
//                        child: attendanceCount == null || attendanceCount.isEmpty
//                            ? Fonts().textW500('0 Check Ins', 12.0, Colors.black38, TextAlign.center)
//                            : Fonts().textW500(
//                            attendanceCount.length == 1 ? '${attendanceCount.length} Check Ins' : '${attendanceCount.length} Check Ins',
//                            12.0, Colors.black38,
//                            TextAlign.center
//                        ),
//                      ),
//                    ],
//                  ),
//                  Column(
//                    children: <Widget>[

//                    ],
//                  ),
//                ],
//              ),
//            ],
//          ),
//        ),
//      ),

  }
}