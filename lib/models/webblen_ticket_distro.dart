class WebblenTicketDistro {
  String eventID;
  String authorID;
  List tickets;
  List fees;
  List discountCodes;

  WebblenTicketDistro({
    this.eventID,
    this.authorID,
    this.tickets,
    this.fees,
    this.discountCodes,
  });

  WebblenTicketDistro.fromMap(Map<String, dynamic> data)
      : this(
    eventID: data['eventID'],
    authorID: data['authorID'],
    tickets: data['tickets'],
    fees: data['fees'],
    discountCodes: data['discountCodes'],
  );

  Map<String, dynamic> toMap() => {
    'eventID': this.eventID,
    'authorID': this.authorID,
    'tickets': this.tickets,
    'fees': this.fees,
    'discountCodes': this.discountCodes,
  };
}