class StripeTransaction {
  String? uid;
  String? purchaserID;
  String? description;
  int? timePosted;
  String? value;

  StripeTransaction({
    this.uid,
    this.purchaserID,
    this.description,
    this.timePosted,
    this.value,
  });

  StripeTransaction.fromMap(Map<String, dynamic> data)
      : this(
          uid: data['uid'],
          purchaserID: data['purchaserID'],
          description: data['description'],
          timePosted: data['timePosted'],
          value: data['value'],
        );

  Map<String, dynamic> toMap() => {
        'uid': this.uid,
        'purchaserID': this.purchaserID,
        'description': this.description,
        'timePosted': this.timePosted,
        'value': this.value,
      };

  bool isValid() {
    bool isValid = true;
    if (this.description == null || this.value == null) {
      isValid = false;
    }
    return isValid;
  }
}
