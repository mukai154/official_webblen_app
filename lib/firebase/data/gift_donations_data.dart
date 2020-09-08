import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/gift_donation.dart';

class GiftDonationsDataService {
  final CollectionReference giftDonationRef = Firestore().collection("gift_donations");
  final CollectionReference userRef = Firestore().collection("webblen_user");

  Future<String> sendGift(String eventID, String uid, GiftDonation giftDonation) async {
    String error;
    DocumentSnapshot snapshot = await userRef.document(uid).get();
    double userWalletAmount = snapshot.data['d']['eventPoints'];
    if (giftDonation.giftAmount > userWalletAmount) {
      error = "insufficient";
    }
    if (error == null) {
      userWalletAmount -= giftDonation.giftAmount;
      await userRef.document(uid).updateData({"d.eventPoints": userWalletAmount});
      await giftDonationRef
          .document(eventID)
          .collection("gift_donations")
          .document(giftDonation.timePostedInMilliseconds.toString())
          .setData(giftDonation.toMap())
          .catchError((e) {
        error = e.details;
      });
    }
    return error;
  }
}
