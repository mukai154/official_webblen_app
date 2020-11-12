import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/widgets/common/containers/round_container.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class EventBlock extends StatefulWidget {
  final String currentUID;
  final WebblenEvent event;
  final int numOfTicsForEvent;
  final VoidCallback viewEventTickets;
  final VoidCallback viewEventDetails;
  final VoidCallback shareEvent;
  final double eventImgSize;
  final double eventDescHeight;

  EventBlock(
      {this.currentUID,
      this.event,
      this.numOfTicsForEvent,
      this.viewEventTickets,
      this.viewEventDetails,
      this.shareEvent,
      this.eventImgSize,
      this.eventDescHeight});

  @override
  _EventBlockState createState() => _EventBlockState();
}

class _EventBlockState extends State<EventBlock> {
  int currentDateTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: GestureDetector(
        onTap: widget.viewEventDetails,
        child: Row(
          children: [
            Container(
              width: 50,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Text(
                    widget.event.startDate.substring(4, widget.event.startDate.length - 6),
                    style: TextStyle(color: CustomColors.webblenRed, fontSize: 25, fontWeight: FontWeight.bold, height: 0.5),
                  ),
                  Text(
                    widget.event.startDate.substring(0, widget.event.startDate.length - 9),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                      widget.event.imageURL,
                    ),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(.6),
                        Colors.black.withOpacity(.1),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        widget.event.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            widget.event.startTime,
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          widget.event.startDateTimeInMilliseconds < currentDateTimeInMilliseconds &&
                                  widget.event.endDateTimeInMilliseconds > currentDateTimeInMilliseconds
                              ? widget.event.isDigitalEvent
                                  ? Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "LIVE",
                                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Happening Now",
                                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                              : widget.event.isDigitalEvent
                                  ? Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Livestream",
                                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : Container(),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        "${widget.event.city}, ${widget.event.province}",
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // return GestureDetector(
    //   onTap: widget.viewEventTickets == null ? widget.viewEventDetails : widget.viewEventTickets,
    //   child: Container(
    //     height: size,
    //     // width: MediaQuery.of(context).size.width - 32,
    //     margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.all(
    //         Radius.circular(8.0),
    //       ),
    //     ),
    //     child: Row(
    //       children: <Widget>[
    //         Column(
    //           children: [
    //             ClipRRect(
    //               borderRadius: BorderRadius.all(Radius.circular(8.0)),
    //               child: CachedNetworkImage(
    //                 imageUrl: widget.event.imageURL,
    //                 fit: BoxFit.cover,
    //                 height: size,
    //                 width: size,
    //               ),
    //             ),
    //           ],
    //         ),
    //         Column(
    //           children: [
    //             Container(
    //               padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
    //               height: size,
    //               width: MediaQuery.of(context).size.width - (125 + 32),
    //               decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.only(
    //                   bottomLeft: Radius.circular(8.0),
    //                   bottomRight: Radius.circular(8.0),
    //                 ),
    //               ),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[
    //                   CustomText(
    //                     context: context,
    //                     text: currentDateInMilliseconds > widget.event.startDateTimeInMilliseconds &&
    //                             currentDateInMilliseconds < widget.event.endDateTimeInMilliseconds
    //                         ? widget.event.isDigitalEvent
    //                             ? "LIVE"
    //                             : "Happening Now"
    //                         : "${widget.event.startDate.substring(0, widget.event.startDate.length - 6)} • ${widget.event.startTime}",
    //                     textColor: currentDateInMilliseconds > widget.event.endDateTimeInMilliseconds ? Colors.black45 : CustomColors.webblenRed,
    //                     textAlign: TextAlign.left,
    //                     fontSize: 14.0,
    //                     fontWeight: FontWeight.w700,
    //                   ),
    //                   Container(
    //                     child: Text(
    //                       widget.event.title,
    //                       style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
    //                       maxLines: 2,
    //                     ),
    //                   ),
    //                   SizedBox(height: 2.0),
    //                   widget.event.isDigitalEvent
    //                       ? Row(
    //                           children: <Widget>[
    //                             Icon(
    //                               FontAwesomeIcons.video,
    //                               size: 12.0,
    //                               color: Colors.black38,
    //                             ),
    //                             SizedBox(width: 8.0),
    //                             Text(
    //                               "Livestream",
    //                               style: TextStyle(color: Colors.black45, fontSize: 14.0, fontWeight: FontWeight.w500),
    //                             ),
    //                           ],
    //                         )
    //                       : Container(
    //                           child: Text(
    //                             widget.event.city == null || widget.event.province == null
    //                                 ? "Location Unavailable"
    //                                 : widget.event.city.contains(widget.event.province)
    //                                     ? widget.event.city
    //                                     : "${widget.event.city}, ${widget.event.province}",
    //                             style: TextStyle(color: Colors.black45, fontSize: 12.0, fontWeight: FontWeight.w500),
    //                             maxLines: 2,
    //                           ),
    //                         ),
    //                   SizedBox(height: 4.0),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: <Widget>[
    //                       widget.numOfTicsForEvent == null
    //                           ? currentDateInMilliseconds > widget.event.startDateTimeInMilliseconds
    //                               ? Container()
    //                               : Container(
    //                                   child: Row(
    //                                     children: <Widget>[
    //                                       GestureDetector(
    //                                         onTap: widget.shareEvent,
    //                                         child: RoundContainer(
    //                                           child: Icon(
    //                                             FontAwesomeIcons.solidShareSquare,
    //                                             size: 16,
    //                                             color: Colors.black45,
    //                                           ),
    //                                           color: CustomColors.transparent,
    //                                           size: 30,
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 )
    //                           : Container(
    //                               child: Row(
    //                                 children: <Widget>[
    //                                   CustomText(
    //                                     context: context,
    //                                     text: widget.numOfTicsForEvent.toString(),
    //                                     textColor: Colors.black45,
    //                                     textAlign: TextAlign.left,
    //                                     fontSize: 18.0,
    //                                     fontWeight: FontWeight.w600,
    //                                   ),
    //                                   SizedBox(width: 4.0),
    //                                   Icon(
    //                                     FontAwesomeIcons.ticketAlt,
    //                                     size: 18.0,
    //                                     color: Colors.black45,
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             )
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
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
                      // TagContainer(
                      //   tag: event.type,
                      //   color: CustomColors.electronBlue,
                      // ),
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
