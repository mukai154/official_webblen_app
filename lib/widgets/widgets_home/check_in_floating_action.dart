import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/styles/flat_colors.dart';

class CheckInFloatingAction extends StatelessWidget {
  final bool checkInAvailable;
  final bool isVirtualEventCheckIn;
  final VoidCallback checkInAction;

  CheckInFloatingAction({
    this.checkInAvailable,
    this.isVirtualEventCheckIn,
    this.checkInAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: checkInAction,
      child: Container(
        height: isVirtualEventCheckIn ? 50 : 70.0,
        width: isVirtualEventCheckIn ? 50 : 70.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(35.0),
          ),
          gradient: LinearGradient(
              colors: checkInAvailable
                  ? [
                      FlatColors.webblenRed,
                      FlatColors.webblenPink,
                    ]
                  : [
                      Colors.white,
                      Colors.white,
                    ]),
          boxShadow: ([
            BoxShadow(
              color: Colors.black12,
              blurRadius: 1.8,
              spreadRadius: 0.5,
              offset: Offset(0.0, 3.0),
            ),
          ]),
        ),
        child: Center(
          child: checkInAvailable
              ? Icon(
                  FontAwesomeIcons.mapMarkerAlt,
                  color: Colors.white,
                  size: isVirtualEventCheckIn ? 20.0 : 30.0,
                )
              : Icon(
                  FontAwesomeIcons.mapMarkerAlt,
                  color: FlatColors.lightAmericanGray,
                  size: isVirtualEventCheckIn ? 20.0 : 30.0,
                ),
        ),
      ),
    );
  }
}

class AltCheckInFloatingAction extends StatelessWidget {
  final bool checkInAvailable;
  final bool isVirtualEventCheckIn;
  final VoidCallback checkInAction;

  AltCheckInFloatingAction({
    this.checkInAvailable,
    this.isVirtualEventCheckIn,
    this.checkInAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: checkInAction,
      child: Container(
        height: isVirtualEventCheckIn ? 50 : 70.0,
        width: isVirtualEventCheckIn ? 50 : 70.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(35.0),
          ),
          color: Colors.black54,
          boxShadow: ([
            BoxShadow(
              color: Colors.black12,
              blurRadius: 1.8,
              spreadRadius: 0.5,
              offset: Offset(0.0, 3.0),
            ),
          ]),
        ),
        child: Center(
          child: Icon(
            FontAwesomeIcons.mapMarkerAlt,
            color: Colors.white12,
            size: isVirtualEventCheckIn ? 20.0 : 30.0,
          ),
        ),
      ),
    );
  }
}
