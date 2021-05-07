import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/custom_colors.dart';

class CheckInFloatingAction extends StatelessWidget {
  final VoidCallback checkInAction;

  CheckInFloatingAction({
    required this.checkInAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: checkInAction,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(35.0),
          ),
          gradient: LinearGradient(colors: [
            CustomColors.webblenRed,
            CustomColors.webblenPink,
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
          child: Icon(
            FontAwesomeIcons.mapMarkerAlt,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class AltCheckInFloatingAction extends StatelessWidget {
  final VoidCallback checkOutAction;

  AltCheckInFloatingAction({
    required this.checkOutAction,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: 0,
      onPressed: checkOutAction,
      child: Icon(
        FontAwesomeIcons.mapMarkerAlt,
        color: Colors.white12,
        size: 20,
      ),
      shape: CircleBorder(),
      elevation: 0.0,
      color: Colors.black26,
      padding: const EdgeInsets.all(12.0),
    );
  }
}
