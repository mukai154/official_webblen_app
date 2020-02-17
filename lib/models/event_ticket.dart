class EventTicket {
  String ticketID;
  String ticketName;
  String purchaserUID;
  String eventID;
  String eventTitle;
  String eventImageURL;
  String address;
  String timezone;
  String startDate;
  String endDate;
  String startTime;
  String endTime;

  EventTicket({
    this.ticketID,
    this.ticketName,
    this.purchaserUID,
    this.eventID,
    this.eventTitle,
    this.eventImageURL,
    this.address,
    this.timezone,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  EventTicket.fromMap(Map<String, dynamic> data)
      : this(
          ticketID: data['ticketID'],
          ticketName: data['ticketName'],
          purchaserUID: data['purchaserUID'],
          eventID: data['eventID'],
          eventTitle: data['eventTitle'],
          eventImageURL: data['eventImageURL'],
          address: data['address'],
          timezone: data['timezone'],
          startDate: data['startDate'],
          endDate: data['endDate'],
          startTime: data['startTime'],
          endTime: data['endTime'],
        );

  Map<String, dynamic> toMap() => {
        'ticketID': this.ticketID,
        'ticketName': this.ticketName,
        'purchaserUID': this.purchaserUID,
        'eventID': this.eventID,
        'eventTitle': this.eventTitle,
        'eventImageURL': this.eventImageURL,
        'address': this.address,
        'timezone': this.timezone,
        'startDate': this.startDate,
        'endDate': this.endDate,
        'startTime': this.startTime,
        'endTime': this.endTime,
      };
}
