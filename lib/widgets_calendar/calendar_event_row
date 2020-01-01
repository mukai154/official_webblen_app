import 'package:flutter/material.dart';
import 'package:webblen/models/calendar_event.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';

class CalendarEventRow extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onTapAction;
  CalendarEventRow({this.event, this.onTapAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        height: 100.0,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.0),
            boxShadow: ([
              BoxShadow(
                color: Colors.black12,
                blurRadius: 1.8,
                spreadRadius: 0.5,
                offset: Offset(0.0, 3.0),
              ),
            ])),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.0),
          onTap: onTapAction,
          child: Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    event.data == null
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                            child: Material(
                              borderRadius: BorderRadius.circular(25.0),
                              color: FlatColors.textFieldGray,
                              child: Padding(padding: EdgeInsets.all(6.0), child: Fonts().textW500(event.data, 12.0, Colors.black, TextAlign.center)),
                            ),
                          ),
                    Row(
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Fonts().textW700(event.title, 22.0, Colors.black, TextAlign.left),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: <Widget>[
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          child: event.type == 'saved'
                              ? Fonts().textW400('Saved Event: ${event.dateTime}', 12.0, FlatColors.lightAmericanGray, TextAlign.left)
                              : event.type == 'created'
                                  ? Fonts().textW400('Created Event: ${event.dateTime}', 12.0, FlatColors.lightAmericanGray, TextAlign.left)
                                  : Fonts().textW400('Reminder: ${event.dateTime}', 12.0, FlatColors.lightAmericanGray, TextAlign.left),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
