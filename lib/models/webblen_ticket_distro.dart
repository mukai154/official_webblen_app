class WebblenTicketDistro {
  String eventID;
  String authorID;
  List tickets;
  List fees;
  List discountCodes;
  bool soldOut;

  WebblenTicketDistro({
    this.eventID,
    this.authorID,
    this.tickets,
    this.fees,
    this.discountCodes,
    this.soldOut,
  });

  WebblenTicketDistro.fromMap(Map<String, dynamic> data)
      : this(
          eventID: data['eventID'],
          authorID: data['authorID'],
          tickets: data['tickets'],
          fees: data['fees'],
          discountCodes: data['discountCodes'],
          soldOut: data['soldOut'],
        );

  Map<String, dynamic> toMap() => {
        'eventID': this.eventID,
        'authorID': this.authorID,
        'tickets': this.tickets,
        'fees': this.fees,
        'discountCodes': this.discountCodes,
        'soldOut': this.soldOut,
      };
}
