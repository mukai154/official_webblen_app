import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/gift_donation.dart';

class GiftDonationsDataService {
  final CollectionReference giftDonationRef = FirebaseFirestore.instance.collection("gift_donations");
  final CollectionReference userRef = FirebaseFirestore.instance.collection("webblen_user");

  Future<String> sendGift(String eventID, String uid, GiftDonation giftDonation) async {
    String error;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    double userWalletAmount = snapshot.data()['d']['eventPoints'];
    if (giftDonation.giftAmount > userWalletAmount) {
      error = "insufficient";
    }
    if (error == null) {
      userWalletAmount -= giftDonation.giftAmount;
      await userRef.doc(uid).update({"d.eventPoints": userWalletAmount});
      await giftDonationRef
          .doc(eventID)
          .collection("gift_donations")
          .doc(giftDonation.timePostedInMilliseconds.toString())
          .set(giftDonation.toMap())
          .catchError((e) {
        error = e.details;
      });
    }
    return error;
  }

  Future<String> updateEventGiftLog(String eventID, String uid, String username, String userImgURL, GiftDonation giftDonation) async {
    String error;
    Map<dynamic, dynamic> donators = {};
    double giftPool;
    DocumentSnapshot snapshot = await giftDonationRef.doc(eventID).get();
    print(snapshot);
    if (snapshot.exists && snapshot.data().isNotEmpty) {
      donators = snapshot.data()['donators'];
      giftPool = snapshot.data()['giftPool'] == null ? 0.0001 : snapshot.data()['giftPool'];
      if (donators[uid] == null) {
        donators[uid] = {'uid': uid, 'username': username, 'userImgURL': userImgURL, 'totalGiftAmount': giftDonation.giftAmount};
      } else {
        Map<String, dynamic> donator = donators[uid];
        double prevGiftAmount = donator['totalGiftAmount'];
        double newGiftAmount = prevGiftAmount + giftDonation.giftAmount;
        donators[uid] = {'uid': uid, 'username': username, 'userImgURL': userImgURL, 'totalGiftAmount': newGiftAmount};
      }
      giftPool += giftDonation.giftAmount;
      await giftDonationRef.doc(eventID).update({'donators': donators, 'giftPool': giftPool});
    } else {
      donators[uid] = {'uid': uid, 'username': username, 'userImgURL': userImgURL, 'totalGiftAmount': giftDonation.giftAmount};
      giftPool = giftDonation.giftAmount;
      await giftDonationRef.doc(eventID).set({'donators': donators, 'giftPool': giftPool});
    }
    return error;
  }
}
