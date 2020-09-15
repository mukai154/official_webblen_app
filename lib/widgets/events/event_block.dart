import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/widgets/common/containers/round_container.dart';
import 'package:webblen/widgets/common/containers/tag_container.dart';
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
  bool eventIsSaved = false;
  List savedBy = [];

  saveUnsaveEvent() {
    print('saving/unsaving event');
    if (savedBy.contains(widget.currentUID)) {
      eventIsSaved = false;
    } else {
      eventIsSaved = true;
    }
    setState(() {});
    EventDataService().saveOrUnsaveEvent(widget.event, widget.currentUID);
  }

  @override
  void initState() {
    if (widget.event.savedBy != null) {
      savedBy = widget.event.savedBy.toList(growable: true);
    }
    if (savedBy.contains(widget.currentUID)) {
      eventIsSaved = true;
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int currentDateInMilliseconds = DateTime.now().millisecondsSinceEpoch;

    final double size = 125;
    return GestureDetector(
      onTap: widget.viewEventTickets == null ? widget.viewEventDetails : widget.viewEventTickets,
      child: Container(
        height: size,
        // width: MediaQuery.of(context).size.width - 32,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Row(
          children: <Widget>[
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: CachedNetworkImage(
                    imageUrl: widget.event.imageURL,
                    fit: BoxFit.cover,
                    height: size,
                    width: size,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                  height: size,
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
                      CustomText(
                        context: context,
                        text: currentDateInMilliseconds > widget.event.startDateTimeInMilliseconds &&
                                currentDateInMilliseconds < widget.event.endDateTimeInMilliseconds
                            ? widget.event.isDigitalEvent ? "LIVE" : "Happening Now"
                            : "${widget.event.startDate.substring(0, widget.event.startDate.length - 6)} • ${widget.event.startTime}",
                        textColor: currentDateInMilliseconds > widget.event.endDateTimeInMilliseconds ? Colors.black45 : CustomColors.webblenRed,
                        textAlign: TextAlign.left,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                      ),
                      Container(
                        child: CustomText(
                          context: context,
                          text: widget.event.title,
                          maxLines: 2,
                          textColor: Colors.black,
                          textAlign: TextAlign.left,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      widget.event.isDigitalEvent
                          ? Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.video,
                                  size: 12.0,
                                  color: Colors.black38,
                                ),
                                SizedBox(width: 8.0),
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
                                CustomText(
                                  context: context,
                                  text: widget.event.city == null || widget.event.province == null
                                      ? "Location Unvailable"
                                      : "${widget.event.city}, ${widget.event.province}",
                                  textColor: Colors.black45,
                                  textAlign: TextAlign.left,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                      SizedBox(height: 6.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          CustomText(
                            context: context,
                            text: widget.event.type,
                            textColor: Colors.black45,
                            textAlign: TextAlign.left,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                          widget.numOfTicsForEvent == null
                              ? currentDateInMilliseconds > widget.event.startDateTimeInMilliseconds
                                  ? Container()
                                  : Container(
                                      child: Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: widget.shareEvent,
                                            child: RoundContainer(
                                              child: Icon(
                                                FontAwesomeIcons.solidShareSquare,
                                                size: 16,
                                                color: Colors.black45,
                                              ),
                                              color: CustomColors.transparent,
                                              size: 30,
                                            ),
                                          ),
//                                          SizedBox(width: 8.0),
//                                          GestureDetector(
//                                            onTap: () => saveUnsaveEvent(),
//                                            child: Icon(
//                                              eventIsSaved ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
//                                              size: 18.0,
//                                              color: eventIsSaved ? Colors.red : Colors.black45,
//                                            ),
//                                          ),
                                        ],
                                      ),
                                    )
                              : Container(
                                  child: Row(
                                    children: <Widget>[
                                      CustomText(
                                        context: context,
                                        text: widget.numOfTicsForEvent.toString(),
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
