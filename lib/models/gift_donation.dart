class GiftDonation {
  String senderUID;
  String receiverUID;
  String senderUsername;
  double giftAmount;
  int giftID;
  int timePostedInMilliseconds;

  GiftDonation({
    this.senderUID,
    this.receiverUID,
    this.senderUsername,
    this.giftAmount,
    this.giftID,
    this.timePostedInMilliseconds,
  });

  GiftDonation.fromMap(Map<String, dynamic> data)
      : this(
          senderUID: data['senderUID'],
          receiverUID: data['receiverUID'],
          senderUsername: data['senderUsername'],
          giftAmount: data['giftAmount'],
          giftID: data['giftID'],
          timePostedInMilliseconds: data['timePostedInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'senderUID': this.senderUID,
        'receiverUID': this.receiverUID,
        'senderUsername': this.senderUsername,
        'giftAmount': this.giftAmount,
        'giftID': this.giftID,
        'timePostedInMilliseconds': this.timePostedInMilliseconds,
      };
}
