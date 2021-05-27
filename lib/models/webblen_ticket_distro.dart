class WebblenTicketDistro {
  String? eventID;
  String? authorID;
  List? tickets;
  List? fees;
  List? discountCodes;
  bool? soldOut;
  List? validTicketIDs;

  WebblenTicketDistro({
    this.eventID,
    this.authorID,
    this.tickets,
    this.fees,
    this.discountCodes,
    this.soldOut,
    this.validTicketIDs,
  });

  WebblenTicketDistro.fromMap(Map<String, dynamic> data)
      : this(
          eventID: data['eventID'],
          authorID: data['authorID'],
          tickets: data['tickets'],
          fees: data['fees'],
          discountCodes: data['discountCodes'],
          soldOut: data['soldOut'],
          validTicketIDs: data['validTicketIDs'],
        );

  Map<String, dynamic> toMap() => {
        'eventID': this.eventID,
        'authorID': this.authorID,
        'tickets': this.tickets,
        'fees': this.fees,
        'discountCodes': this.discountCodes,
        'soldOut': this.soldOut,
        'validTicketIDs': this.validTicketIDs,
      };

  bool isValid() {
    bool isValid = true;
    if (this.eventID == null) {
      isValid = false;
    }
    return false;
  }
}
