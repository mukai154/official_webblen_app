class DebitCardInfo {
  String brand;
  int expMonth;
  int expYear;
  String last4;
  int funding;
  String name;

  DebitCardInfo({
    this.brand,
    this.expMonth,
    this.expYear,
    this.last4,
    this.funding,
    this.name,
  });

  DebitCardInfo.fromMap(Map<String, dynamic> data)
      : this(
          brand: data['brand'],
          expMonth: data['expMonth'],
          expYear: data['expYear'],
          last4: data['last4'],
          funding: data['funding'],
          name: data['name'],
        );

  Map<String, dynamic> toMap() => {
        'brand': this.brand,
        'expMonth': this.expMonth,
        'expYear': this.expYear,
        'last4': this.last4,
        'funding': this.funding,
        'name': this.name,
      };
}
