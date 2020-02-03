class EventTicket {
  String ticketID;
  String purchaserUID;
  String eventID;
  String address;
  double lat;
  double lon;
  String timezone;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String price;

  EventTicket({
    this.ticketID,
    this.purchaserUID,
    this.eventID,
    this.address,
    this.lat,
    this.lon,
    this.timezone,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.price,
  });

  EventTicket.fromMap(Map<String, dynamic> data)
      : this(
          ticketID: data['ticketID'],
          purchaserUID: data['purchaserUID'],
          eventID: data['eventID'],
          address: data['address'],
          lat: data['lat'],
          lon: data['lon'],
          timezone: data['timezone'],
          startDate: data['startDate'],
          endDate: data['endDate'],
          startTime: data['startTime'],
          endTime: data['endTime'],
          price: data['price'],
        );

  Map<String, dynamic> toMap() => {
        'ticketID': this.ticketID,
        'purchaserUID': this.purchaserUID,
        'address': this.address,
        'lat': this.lat,
        'lon': this.lon,
        'timezone': this.timezone,
        'timezone': this.timezone,
        'startDate': this.startDate,
        'endDate': this.endDate,
        'startTime': this.startTime,
        'endTime': this.endTime,
        'price': this.price,
      };
}
