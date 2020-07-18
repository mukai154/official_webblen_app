class TicketDistro {
  String eventID;
  String authorID;
  List tickets;
  List fees;
  List discountCodes;
  List usedTicketIDs;
  List validTicketIDs;

  TicketDistro({
    this.eventID,
    this.authorID,
    this.tickets,
    this.fees,
    this.discountCodes,
    this.usedTicketIDs,
    this.validTicketIDs,
  });

  TicketDistro.fromMap(Map<String, dynamic> data)
      : this(
          eventID: data['eventID'],
          authorID: data['authorID'],
          tickets: data['tickets'],
          fees: data['fees'],
          discountCodes: data['discountCodes'],
          usedTicketIDs: data['usedTicketIDs'],
          validTicketIDs: data['validTicketIDs'],
        );

  Map<String, dynamic> toMap() => {
        'eventID': this.eventID,
        'authorID': this.authorID,
        'tickets': this.tickets,
        'fees': this.fees,
        'discountCodes': this.discountCodes,
        'usedTicketIDs': this.usedTicketIDs,
        'validTicketIDs': this.validTicketIDs,
      };
}
