class EventTicketDistribution {
  String eventID;
  List tickets;
  List fees;
  List validTicketIDs;
  List usedTicketIDs;

  EventTicketDistribution({
    this.eventID,
    this.tickets,
    this.fees,
    this.validTicketIDs,
    this.usedTicketIDs,
  });

  EventTicketDistribution.fromMap(Map<String, dynamic> data)
      : this(
          eventID: data['eventID'],
          tickets: data['tickets'],
          fees: data['fees'],
          validTicketIDs: data['validTicketIDs'],
          usedTicketIDs: data['usedTicketIDs'],
        );

  Map<String, dynamic> toMap() => {
        'eventID': this.eventID,
        'tickets': this.tickets,
        'fees': this.fees,
        'validTicketIDs': this.validTicketIDs,
        'usedTicketIDs': this.usedTicketIDs,
      };
}
