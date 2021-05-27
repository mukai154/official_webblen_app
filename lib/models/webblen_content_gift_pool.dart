class WebblenContentGiftPool {
  String? id;
  String? hostID;
  Map<dynamic, dynamic>? gifters;
  double? totalGiftAmount;
  bool? paidOut;

  WebblenContentGiftPool({
    this.id,
    this.hostID,
    this.gifters,
    this.totalGiftAmount,
    this.paidOut,
  });

  WebblenContentGiftPool.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          hostID: data['hostID'],
          gifters: data['gifters'],
          totalGiftAmount: data['totalGiftAmount'].toDouble(),
          paidOut: data['paidOut'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'hostID': this.hostID,
        'gifters': this.gifters,
        'totalGiftAmount': this.totalGiftAmount,
        'paidOut': this.paidOut,
      };

  bool isValid() {
    bool isValid = true;
    if (this.id == null) {
      isValid = false;
    }
    return isValid;
  }
}
