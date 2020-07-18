import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/models/event_ticket.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class EventTicketWidget {
  showEventTicket(BuildContext context, EventTicket ticket) {
    var alertStyle = AlertStyle(
      backgroundColor: Colors.black,
      animationType: AnimationType.grow,
      isCloseButton: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
    );
    Alert(
      context: context,
      type: AlertType.none,
      style: alertStyle,
      title: "",
      content: TicketWidget(ticket: ticket),
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          child: Container(
            child: CustomText(
              context: context,
              text: "Close",
              textColor: Colors.white,
              textAlign: TextAlign.left,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ).show();
  }
}

class TicketWidget extends StatelessWidget {
  final EventTicket ticket;
  TicketWidget({this.ticket});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.0,
      //height: 500.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            height: 220,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: QrImage(
              data: ticket.ticketID,
              version: QrVersions.auto,
              size: 200.0,
            ),
            //              Column(
            //                crossAxisAlignment: CrossAxisAlignment.stretch,
            //                children: <Widget>[
            //                  Row(
            //                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                    children: <Widget>[
            //                      WebblenLogo(),
            //                      TagContainer(tag: "Concert/Performance"),
            //                    ],
            //                  ),
            //                  SizedBox(height: 10.0),
            //                  Center(
            //                    child: QrImage(
            //                      data: "1234567890",
            //                      version: QrVersions.auto,
            //                      size: 150.0,
            //                    ),
            //                  ),
            //                ],
            //              ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 20,
                width: 10,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
              Container(
                height: 20,
                width: 10,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 250,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(4.0),
                  margin: EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      color: CustomColors.textFieldGray),
                  child: CustomText(
                    context: context,
                    text: ticket.eventTitle,
                    textColor: Colors.black,
                    textAlign: TextAlign.center,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CustomText(
                  context: context,
                  text: "Ticket Type:",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  context: context,
                  text: "${ticket.ticketName}",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 8.0),
                CustomText(
                  context: context,
                  text: "City & Province:",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  context: context,
                  text: "Fargo, ND",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 8.0),
                CustomText(
                  context: context,
                  text: "Street Address:",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  context: context,
                  text: "${ticket.address}",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 8.0),
                CustomText(
                  context: context,
                  text: "Start Date & Time:",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  context: context,
                  text: "${ticket.startDate} | ${ticket.startTime}",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 8.0),
                CustomText(
                  context: context,
                  text: "End Date & Time:",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  context: context,
                  text: "${ticket.endDate} | ${ticket.endTime}",
                  textColor: Colors.black,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
