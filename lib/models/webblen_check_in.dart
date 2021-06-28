class CheckInData {
  int? checkInTimeInMilliseconds;
  int? checkOutTimeInMilliseconds;

  CheckInData({
    this.checkInTimeInMilliseconds,
    this.checkOutTimeInMilliseconds,
  });

  CheckInData.fromMap(Map<String, dynamic> data)
      : this(
          checkInTimeInMilliseconds: data['checkInTimeInMilliseconds'],
          checkOutTimeInMilliseconds: data['checkOutTimeInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'checkInTimeInMilliseconds': checkInTimeInMilliseconds,
        'checkOutTimeInMilliseconds': checkOutTimeInMilliseconds,
      };
}

class WebblenCheckIn {
  String? uid;
  List<CheckInData>? checkInData;

  WebblenCheckIn({
    this.uid,
    this.checkInData,
  });

  WebblenCheckIn.fromMap(Map<String, dynamic> data)
      : this(
          uid: data['uid'],
          checkInData: data['checkInData'] != null
              ? data['checkInData']
                  .map((val) => WebblenCheckIn.fromMap(val))
                  .cast<WebblenCheckIn>()
                  .toList()
              : [],
        );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'checkInData': checkInData != null
            ? checkInData!.map((val) => val.toMap()).toList()
            : [],
      };
}
