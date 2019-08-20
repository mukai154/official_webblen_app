class WebblenNotification {

  String notificationData;
  String notificationTitle;
  String notificationDescription;
  String notificationSender;
  String notificationType;
  String notificationKey;
  String notificationExpirationDate;
  int notificationExpDate;
  String uid;
  bool sponsoredNotification;
  bool notificationSeen;
  String messageToken;

  WebblenNotification({
    this.notificationData,
    this.notificationTitle,
    this.notificationDescription,
    this.notificationSender,
    this.notificationType,
    this.notificationKey,
    this.notificationExpirationDate,
    this.notificationExpDate,
    this.uid,
    this.sponsoredNotification,
    this.notificationSeen,
    this.messageToken
  });

  WebblenNotification.fromMap(Map<String, dynamic> data)
      : this(notificationData: data['notificationData'],
      notificationTitle: data['notificationTitle'],
      notificationDescription: data['notificationDescription'],
      notificationSender: data['notificationSender'],
      notificationType: data['notificationType'],
      notificationKey: data['notificationKey'],
      notificationExpirationDate: data['notificationExpirationDate'],
      notificationExpDate: data['notificationExpDate'],
      uid: data['uid'],
      sponsoredNotification: data['sponsoredNotification'],
      notificationSeen: data['notificationSeen'],
      messageToken: data['messageToken']
  );

  Map<String, dynamic> toMap() => {
    'notificationData': this.notificationData,
    'notificationTitle': this.notificationTitle,
    'notificationDescription': this.notificationDescription,
    'notificationSender': this.notificationSender,
    'notificationType': this.notificationType,
    'notificationKey': this.notificationKey,
    'notificationExpirationDate': this.notificationExpirationDate,
    'notificationExpDate': this.notificationExpDate,
    'uid': this.uid,
    'sponsoredNotification': this.sponsoredNotification,
    'notificationSeen': this.notificationSeen,
    'messageToken': this.messageToken
  };
}