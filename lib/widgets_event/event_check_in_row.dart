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
import 'package:webblen/firebase_data/event_data.dart';

class NearbyEventCheckInRow extends StatefulWidget {

  final Event event;
  final String uid;
  final VoidCallback viewEventAction;
  final VoidCallback checkInAction;
  final VoidCallback checkoutAction;

  NearbyEventCheckInRow({this.uid, this.event, this.viewEventAction, this.checkInAction, this.checkoutAction});

  @override
  _NearbyEventCheckInRowState createState() => _NearbyEventCheckInRowState();
}

class _NearbyEventCheckInRowState extends State<NearbyEventCheckInRow> {

  @override
  Widget build(BuildContext context) {
    List attendanceCount = widget.event.attendees;
    String endTime = TimeCalc().showTimeRemaining(widget.event.endDateInMilliseconds);
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
                          onPressed: widget.event.attendees.contains(widget.uid) ? widget.checkoutAction : widget.checkInAction,
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
  }
}