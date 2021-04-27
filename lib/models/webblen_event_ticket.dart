class WebblenEventTicket {
  String? id;
  String? name;
  String? purchaserUID;
  String? eventID;
  String? eventTitle;
  String? eventImageURL;
  String? address;
  String? timezone;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  bool? used;

  WebblenEventTicket({
    this.id,
    this.name,
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
    this.used,
  });

  WebblenEventTicket.fromMap(Map<String, dynamic> data)
      : this(
    id: data['id'],
    name: data['name'],
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
    used: data['used'],
  );

  Map<String, dynamic> toMap() => {
    'id': this.id,
    'name': this.name,
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
    'used': this.used,
  };
}