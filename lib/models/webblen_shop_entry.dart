import 'package:cloud_firestore/cloud_firestore.dart';

class WebblenShopEntry {
  int? assetId;
  String? creatorUid;
  String? title;
  String? description;
  double? price;
  String? transactionCurrency;
  int? creationTimeInMilliseconds;

  WebblenShopEntry({
    this.assetId,
    this.creatorUid,
    this.title,
    this.description,
    this.price,
    this.transactionCurrency,
    this.creationTimeInMilliseconds,
  });

  WebblenShopEntry.fromMap(Map<String, dynamic> data)
      : this(
          assetId: data['assetId'],
          creatorUid: data['creatorUid'],
          title: data['title'],
          description: data['description'],
          price: data['price'],
          transactionCurrency: data['transactionCurrency'],
          creationTimeInMilliseconds: data['creationTimeInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'assetId': this.assetId,
        'creatorUid': this.creatorUid,
        'title': this.title,
        'description': this.description,
        'price': this.price,
        'transactionCurrency': this.transactionCurrency,
        'creationTimeInMilliseconds': this.creationTimeInMilliseconds,
      };
}
