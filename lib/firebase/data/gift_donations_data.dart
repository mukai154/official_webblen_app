import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/gift_donation.dart';

class GiftDonationsDataService {
  final CollectionReference giftDonationRef = Firestore().collection("gift_donations");

  //CREATE
  Future<String> sendGift(String eventID, GiftDonation giftDonation) async {
    String error;
    print(giftDonation.toMap());
    await giftDonationRef
        .document(eventID)
        .collection("gift_donations")
        .document(giftDonation.timePostedInMilliseconds.toString())
        .setData(giftDonation.toMap())
        .catchError((e) {
      error = e.details;
    });
    return error;
  }
}
