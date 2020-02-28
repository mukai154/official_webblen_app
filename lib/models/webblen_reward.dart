class WebblenReward {
  String rewardKey;
  String rewardProviderName;
  String rewardDescription;
  String rewardImagePath;
  double rewardLat;
  double rewardLon;
  double rewardCost;
  int amountAvailable;
  String expirationDate;
  String rewardType;
  String rewardUrl;
  String rewardPromoCode;
  String rewardBarcodeNumber;
  String rewardCategory;
  bool exclusiveReward;

  WebblenReward({
    this.rewardKey,
    this.rewardProviderName,
    this.rewardDescription,
    this.rewardImagePath,
    this.rewardLat,
    this.rewardLon,
    this.rewardCost,
    this.amountAvailable,
    this.expirationDate,
    this.rewardType,
    this.rewardUrl,
    this.rewardPromoCode,
    this.rewardBarcodeNumber,
    this.rewardCategory,
    this.exclusiveReward,
  });

  WebblenReward.fromMap(Map<String, dynamic> data)
      : this(
          rewardKey: data['rewardKey'],
          rewardProviderName: data['rewardProviderName'],
          rewardDescription: data['rewardDescription'],
          rewardImagePath: data['rewardImagePath'],
          rewardLat: data['rewardLat'],
          rewardLon: data['rewardLon'],
          rewardCost: data['rewardCost'],
          amountAvailable: data['amountAvailable'],
          expirationDate: data['expirationDate'],
          rewardType: data['rewardType'],
          rewardUrl: data['rewardUrl'],
          rewardPromoCode: data['rewardPromoCode'],
          rewardBarcodeNumber: data['rewardBarcodeNumber'],
          rewardCategory: data['rewardCategory'],
          exclusiveReward: data['exclusiveReward'],
        );

  Map<String, dynamic> toMap() => {
        'rewardKey': this.rewardKey,
        'rewardProviderName': this.rewardProviderName,
        'rewardDescription': this.rewardDescription,
        'rewardImagePath': this.rewardImagePath,
        'rewardLat': this.rewardLat,
        'rewardLon': this.rewardLon,
        'rewardCost': this.rewardCost,
        'amountAvailable': this.amountAvailable,
        'expirationDate': this.expirationDate,
        'rewardType': this.rewardType,
        'rewardUrl': this.rewardUrl,
        'rewardPromoCode': this.rewardPromoCode,
        'rewardBarcodeNumber': this.rewardBarcodeNumber,
        'rewardCategory': this.rewardCategory,
        'exclusiveReward': this.exclusiveReward,
      };
}
