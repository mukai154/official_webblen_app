import 'package:flutter/material.dart';
import 'package:webblen/models/event_ticket.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

import 'event_ticket_widget.dart';

class EventPurchasedTicketsList extends StatelessWidget {
  final List<EventTicket> tickets;
  final List validTickets;
  final List usedTickets;
  EventPurchasedTicketsList({this.tickets, this.validTickets, this.usedTickets});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tickets.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.only(top: 12.0),
          //height: 40.0,
          //width: MediaQuery.of(context).size.width * 0.60,
          child: GestureDetector(
            onTap: () => EventTicketWidget().showEventTicket(context, tickets[index]),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomText(
                    context: context,
                    text: validTickets.contains(tickets[index].ticketID) ? "${tickets[index].ticketName}" : "${tickets[index].ticketName} (Used)",
                    textColor: validTickets.contains(tickets[index].ticketID) ? Colors.blueAccent : Colors.black45,
                    textAlign: TextAlign.left,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                  CustomText(
                    context: context,
                    text: "Ticket ID: ${tickets[index].ticketID}",
                    textColor: Colors.black45,
                    textAlign: TextAlign.left,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
