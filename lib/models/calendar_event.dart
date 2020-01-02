class CalendarEvent {
  String key;
  String title;
  String description;
  String type;
  String data;
  String timezone;
  String dateTime;

  CalendarEvent({
    this.key,
    this.title,
    this.description,
    this.type,
    this.data,
    this.timezone,
    this.dateTime,
  });

  CalendarEvent.fromMap(Map<String, dynamic> data)
      : this(
            key: data['key'],
            title: data['title'],
            description: data['description'],
            type: data['type'],
            data: data['data'],
            timezone: data['timezone'],
            dateTime: data['dateTime']);

  Map<String, dynamic> toMap() => {
        'key': this.key,
        'title': this.title,
        'description': this.description,
        'type': this.type,
        'data': this.data,
        'timezone': this.timezone,
        'dateTime': this.dateTime,
      };
}
