import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/widgets/common/containers/round_container.dart';
import 'package:webblen/widgets/common/containers/tag_container.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class EventBlock extends StatelessWidget {
  final WebblenEvent event;
  final int numOfTicsForEvent;
  final VoidCallback viewEventTickets;
  final VoidCallback viewEventDetails;
  final VoidCallback shareEvent;
  final double eventImgSize;
  final double eventDescHeight;
  EventBlock({this.event, this.numOfTicsForEvent, this.viewEventTickets, this.viewEventDetails, this.shareEvent, this.eventImgSize, this.eventDescHeight});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: viewEventTickets == null ? viewEventDetails : viewEventTickets,
      child: Container(
        height: 125,
        // width: MediaQuery.of(context).size.width - 32,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1.5,
              blurRadius: 1.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0)),
                  child: CachedNetworkImage(
                    imageUrl: event.imageURL,
                    fit: BoxFit.cover,
                    height: 125,
                    width: 125,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  height: 125,
                  width: MediaQuery.of(context).size.width - (125 + 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: CustomText(
                          context: context,
                          text: event.title,
                          textColor: Colors.black,
                          textAlign: TextAlign.left,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      event.isDigitalEvent
                          ? Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.video,
                                  size: 14.0,
                                  color: Colors.black38,
                                ),
                                SizedBox(width: 6.0),
                                CustomText(
                                  context: context,
                                  text: "Livestream",
                                  textColor: Colors.black45,
                                  textAlign: TextAlign.left,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            )
                          : Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.mapMarkerAlt,
                                  size: 14.0,
                                  color: Colors.black38,
                                ),
                                SizedBox(width: 4.0),
                                CustomText(
                                  context: context,
                                  text: "${event.city}, ${event.province}",
                                  textColor: Colors.black45,
                                  textAlign: TextAlign.left,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                      SizedBox(height: 4.0),
                      CustomText(
                        context: context,
                        text: "${event.startDate} | ${event.startTime} ${event.timezone}",
                        textColor: Colors.black45,
                        textAlign: TextAlign.left,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 6.0),
                      Container(
                        height: 1.0,
                        color: Colors.black12,
                      ),
                      SizedBox(height: 6.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TagContainer(tag: event.type, color: CustomColors.electronBlue),
                          numOfTicsForEvent == null
                              ? GestureDetector(
                                  onTap: shareEvent,
                                  child: RoundContainer(
                                    child: Icon(
                                      Icons.share,
                                      size: 12.0,
                                      color: Colors.black45,
                                    ),
                                    color: CustomColors.textFieldGray,
                                    size: 30,
                                  ),
                                )
                              : Container(
                                  child: Row(
                                    children: <Widget>[
                                      CustomText(
                                        context: context,
                                        text: numOfTicsForEvent.toString(),
                                        textColor: Colors.black45,
                                        textAlign: TextAlign.left,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      SizedBox(width: 4.0),
                                      Icon(
                                        FontAwesomeIcons.ticketAlt,
                                        size: 18.0,
                                        color: Colors.black45,
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OldEventBlock extends StatelessWidget {
  final WebblenEvent event;
  final int numOfTicsForEvent;
  final VoidCallback viewEventTickets;
  final VoidCallback viewEventDetails;
  final VoidCallback shareEvent;
  final double eventImgSize;
  final double eventDescHeight;
  OldEventBlock({this.event, this.numOfTicsForEvent, this.viewEventTickets, this.viewEventDetails, this.shareEvent, this.eventImgSize, this.eventDescHeight});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: viewEventTickets == null ? viewEventDetails : viewEventTickets,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        width: eventImgSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1.5,
              blurRadius: 1.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
              child: CachedNetworkImage(
                imageUrl: event.imageURL,
                fit: BoxFit.cover,
                height: eventImgSize,
                width: eventImgSize,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              height: eventDescHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CustomText(
                      context: context,
                      text: event.title,
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  event.isDigitalEvent
                      ? Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.video,
                              size: 14.0,
                              color: Colors.black38,
                            ),
                            SizedBox(width: 6.0),
                            CustomText(
                              context: context,
                              text: "Livestream",
                              textColor: Colors.black45,
                              textAlign: TextAlign.left,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.mapMarkerAlt,
                              size: 14.0,
                              color: Colors.black38,
                            ),
                            SizedBox(width: 4.0),
                            CustomText(
                              context: context,
                              text: "${event.city}, ${event.province}",
                              textColor: Colors.black45,
                              textAlign: TextAlign.left,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                  SizedBox(height: 4.0),
                  CustomText(
                    context: context,
                    text: "${event.startDate} | ${event.startTime} ${event.timezone}",
                    textColor: Colors.black45,
                    textAlign: TextAlign.left,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 6.0),
                  Container(
                    height: 1.0,
                    color: Colors.black12,
                  ),
                  SizedBox(height: 6.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TagContainer(tag: event.type, color: CustomColors.electronBlue),
                      numOfTicsForEvent == null
                          ? GestureDetector(
                              onTap: shareEvent,
                              child: RoundContainer(
                                child: Icon(
                                  Icons.share,
                                  size: 12.0,
                                  color: Colors.black45,
                                ),
                                color: CustomColors.textFieldGray,
                                size: 30,
                              ),
                            )
                          : Container(
                              child: Row(
                                children: <Widget>[
                                  CustomText(
                                    context: context,
                                    text: numOfTicsForEvent.toString(),
                                    textColor: Colors.black45,
                                    textAlign: TextAlign.left,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  SizedBox(width: 4.0),
                                  Icon(
                                    FontAwesomeIcons.ticketAlt,
                                    size: 18.0,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EventTicketBlock extends StatelessWidget {
  final WebblenEvent event;
  final int numOfTicsForEvent;
  final VoidCallback viewEventTickets;
  final VoidCallback viewEventDetails;
  final VoidCallback shareEvent;
  final double eventDescHeight;
  EventTicketBlock({this.event, this.numOfTicsForEvent, this.viewEventTickets, this.viewEventDetails, this.shareEvent, this.eventDescHeight});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: viewEventTickets == null ? viewEventDetails : viewEventTickets,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1.5,
              blurRadius: 1.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              height: eventDescHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CustomText(
                      context: context,
                      text: event.title,
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Row(
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.mapMarkerAlt,
                        size: 14.0,
                        color: Colors.black38,
                      ),
                      SizedBox(width: 4.0),
                      CustomText(
                        context: context,
                        text: "${event.city}, ${event.province}",
                        textColor: Colors.black45,
                        textAlign: TextAlign.left,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  CustomText(
                    context: context,
                    text: "${event.startDate} | ${event.startTime} ${event.timezone}",
                    textColor: Colors.black45,
                    textAlign: TextAlign.left,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 6.0),
                  Container(
                    height: 1.0,
                    color: Colors.black12,
                  ),
                  SizedBox(height: 6.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TagContainer(
                        tag: event.type,
                        color: CustomColors.electronBlue,
                      ),
                      numOfTicsForEvent == null
                          ? GestureDetector(
                              onTap: shareEvent,
                              child: RoundContainer(
                                child: Icon(
                                  Icons.share,
                                  size: 12.0,
                                  color: Colors.black45,
                                ),
                                color: CustomColors.textFieldGray,
                                size: 30,
                              ),
                            )
                          : Container(
                              child: Row(
                                children: <Widget>[
                                  CustomText(
                                    context: context,
                                    text: numOfTicsForEvent.toString(),
                                    textColor: Colors.black45,
                                    textAlign: TextAlign.left,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  SizedBox(width: 4.0),
                                  Icon(
                                    FontAwesomeIcons.ticketAlt,
                                    size: 18.0,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
