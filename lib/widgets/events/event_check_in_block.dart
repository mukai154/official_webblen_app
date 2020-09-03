import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class EventCheckInBlock extends StatefulWidget {
  final String currentUID;
  final double userAP;
  final WebblenEvent event;
  final VoidCallback viewEventDetails;

  EventCheckInBlock({
    this.currentUID,
    this.userAP,
    this.event,
    this.viewEventDetails,
  });

  @override
  _EventCheckInBlockState createState() => _EventCheckInBlockState();
}

class _EventCheckInBlockState extends State<EventCheckInBlock> {
  bool isLoading = false;
  bool didCheckIn = false;
  List attendees = [];

  checkInOutOfEvent() {
    isLoading = true;
    setState(() {});
    if (attendees.contains(widget.currentUID)) {
      attendees.remove(widget.currentUID);
      didCheckIn = false;
      EventDataService().checkoutAndUpdateEventPayout(widget.event.id, widget.currentUID).then((res) {
        isLoading = false;
        setState(() {});
      });
    } else {
      attendees.add(widget.currentUID);
      didCheckIn = true;
      EventDataService().checkInAndUpdateEventPayout(widget.event.id, widget.currentUID, widget.userAP).then((res) {
        isLoading = false;
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    attendees = widget.event.attendees;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int currentDateInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    int twoHoursPastEventDateInMilliseconds = widget.event.startDateTimeInMilliseconds + 7200000;

    final double size = 120;
    return GestureDetector(
      onTap: widget.viewEventDetails,
      child: Container(
        height: size,
        // width: MediaQuery.of(context).size.width - 32,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          //          boxShadow: [
          //            BoxShadow(
          //              color: Colors.black12,
          //              spreadRadius: 1.5,
          //              blurRadius: 1.0,
          //              offset: Offset(0.0, 0.0),
          //            ),
          //          ],
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
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomText(
                        context: context,
                        text: currentDateInMilliseconds > widget.event.startDateTimeInMilliseconds &&
                                currentDateInMilliseconds < widget.event.endDateTimeInMilliseconds
                            ? "Happening Now"
                            : "${widget.event.startDate.substring(0, widget.event.startDate.length - 6)} • ${widget.event.startTime}",
                        textColor: CustomColors.webblenRed,
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
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.0),

//                      Container(
//                        height: 1.0,
//                        color: Colors.black12,
//                      ),
                      SizedBox(height: 6.0),
                      isLoading
                          ? CustomCircleProgress(10, 10, 10, 10, CustomColors.lightAmericanGray)
                          : attendees.contains(widget.currentUID)
                              ? CustomColorButton(
                                  text: "Check Out",
                                  textColor: Colors.white,
                                  backgroundColor: Colors.red,
                                  height: 35.0,
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  onPressed: () => checkInOutOfEvent(),
                                )
                              : CustomColorButton(
                                  text: "Check In",
                                  textColor: Colors.white,
                                  backgroundColor: CustomColors.darkMountainGreen,
                                  height: 35.0,
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  onPressed: () => checkInOutOfEvent(),
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
