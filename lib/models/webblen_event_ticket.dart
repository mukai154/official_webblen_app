class WebblenEventTicket {
  String address;
  String endDate;
  String endTime;
  String eventID;
  String eventImageURL;
  String eventTitle;
  String purchaserUID;
  String startDate;
  String startTime;
  String ticketID;
  String ticketName;
  String timeZone;

  WebblenEventTicket({
    this.address,
    this.endDate,
    this.endTime,
    this.eventID,
    this.eventImageURL,
    this.eventTitle,
    this.purchaserUID,
    this.startDate,
    this.startTime,
    this.ticketID,
    this.ticketName,
    this.timeZone,
  });

  WebblenEventTicket.fromMap(Map<String, dynamic> data)
      : this(
          address: data['address'],
          endDate: data['endDate'],
          endTime: data['endTime'],
          eventID: data['eventID'],
          eventImageURL: data['eventImageURL'],
          eventTitle: data['eventTitle'],
          purchaserUID: data['purchaserUID'],
          startDate: data['startDate'],
          startTime: data['startTime'],
          ticketID: data['ticketID'],
          ticketName: data['ticketName'],
          timeZone: data['timeZone'],
        );

  Map<String, dynamic> toMap() => {
        'address': this.address,
        'endDate': this.endDate,
        'endTime': this.endTime,
        'eventID': this.eventID,
        'eventImageURL': this.eventImageURL,
        'eventTitle': this.eventTitle,
        'purchaserUID': this.purchaserUID,
        'startDate': this.startDate,
        'startTime': this.startTime,
        'ticketID': this.ticketID,
        'ticketName': this.ticketName,
        'timeZone': this.timeZone,
      };
}
