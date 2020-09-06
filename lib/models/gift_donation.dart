class GiftDonation {
  String senderUID;
  String receiverUID;
  String senderUsername;
  double giftAmount;
  String giftName;
  int timePostedInMilliseconds;

  GiftDonation({
    this.senderUID,
    this.receiverUID,
    this.senderUsername,
    this.giftAmount,
    this.giftName,
    this.timePostedInMilliseconds,
  });

  GiftDonation.fromMap(Map<String, dynamic> data)
      : this(
          senderUID: data['senderUID'],
          receiverUID: data['receiverUID'],
          senderUsername: data['senderUsername'],
          giftAmount: data['giftAmount'],
          giftName: data['giftName'],
          timePostedInMilliseconds: data['timePostedInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'senderUID': this.senderUID,
        'receiverUID': this.receiverUID,
        'senderUsername': this.senderUsername,
        'giftAmount': this.giftAmount,
        'giftName': this.giftName,
        'timePostedInMilliseconds': this.timePostedInMilliseconds,
      };
}
