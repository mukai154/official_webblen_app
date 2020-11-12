class WebblenReward {
  String id;
  String type;
  String providerID;
  String title;
  String description;
  String imageURL;
  bool isGlobalReward;
  List nearbyZipcodes;
  double cost;
  int amountAvailable;
  String url;
  String expirationDate;

  WebblenReward({
    this.id,
    this.type,
    this.providerID,
    this.title,
    this.description,
    this.imageURL,
    this.isGlobalReward,
    this.nearbyZipcodes,
    this.cost,
    this.amountAvailable,
    this.url,
    this.expirationDate,
  });

  WebblenReward.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          type: data['type'],
          providerID: data['providerID'],
          title: data['title'],
          description: data['description'],
          imageURL: data['imageURL'],
          isGlobalReward: data['isGlobalReward'],
          nearbyZipcodes: data['nearbyZipcodes'],
          cost: data['cost'],
          amountAvailable: data['amountAvailable'],
          url: data['url'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'type': this.type,
        'providerID': this.providerID,
        'title': this.title,
        'description': this.description,
        'imageURL': this.imageURL,
        'isGlobalReward': this.isGlobalReward,
        'nearbyZipcodes': this.nearbyZipcodes,
        'cost': this.cost,
        'amountAvailable': this.amountAvailable,
        'url': this.url,
        'expirationDate': this.expirationDate,
      };
}
