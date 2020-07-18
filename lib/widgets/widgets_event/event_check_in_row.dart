import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class NearbyEventCheckInRow extends StatefulWidget {
  final WebblenEvent event;
  final String uid;
  final VoidCallback viewEventAction;
  final VoidCallback checkInAction;
  final VoidCallback checkoutAction;

  NearbyEventCheckInRow({
    this.uid,
    this.event,
    this.viewEventAction,
    this.checkInAction,
    this.checkoutAction,
  });

  @override
  _NearbyEventCheckInRowState createState() => _NearbyEventCheckInRowState();
}

class _NearbyEventCheckInRowState extends State<NearbyEventCheckInRow> {
  DateFormat dateFormatter = DateFormat("h:mm a");

  @override
  Widget build(BuildContext context) {
    List attendanceCount = widget.event.attendees;
    DateTime eventEndDateTime = DateTime.fromMillisecondsSinceEpoch(widget.event.startDateTimeInMilliseconds + 7200000);
    return GestureDetector(
      onTap: widget.viewEventAction,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 8.0,
        ),
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
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16.0,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0,
                    top: 4.0,
                    bottom: 8.0,
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(24.0),
                    color: FlatColors.textFieldGray,
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Fonts().textW500('Ends at ${dateFormatter.format(eventEndDateTime)}', 12.0, Colors.black87, TextAlign.center),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                top: 16.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    FlatColors.transparent,
                  ],
                  begin: Alignment(0.0, 1.0),
                  end: Alignment(0.0, -1.0),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: Fonts().textW700(
                      '${widget.event.title}',
                      26.0,
                      Colors.white,
                      TextAlign.left,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                        child: Row(
                          children: [
                            attendanceCount == null || attendanceCount.isEmpty
                                ? Fonts().textW500(
                                    '0 Check Ins',
                                    14.0,
                                    Colors.white,
                                    TextAlign.center,
                                  )
                                : Fonts().textW500(
                                    attendanceCount.length == 1 ? '${attendanceCount.length} Check Ins' : '${attendanceCount.length} Check Ins',
                                    14.0,
                                    Colors.white,
                                    TextAlign.center,
                                  ),
                          ],
                        ),
                      ),
                      Spacer(),
                      CustomColorButton(
                        text: widget.event.attendees.contains(widget.uid) ? 'Check Out' : 'Check In',
                        textColor: Colors.white,
                        backgroundColor: widget.event.attendees.contains(widget.uid) ? Colors.redAccent : FlatColors.darkMountainGreen,
                        height: 45.0,
                        width: 100.0,
                        hPadding: 8.0,
                        vPadding: 0.0,
                        onPressed: widget.event.attendees.contains(widget.uid) ? widget.checkoutAction : widget.checkInAction,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
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
