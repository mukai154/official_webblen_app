import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_content_gift_pool.dart';
import 'package:webblen/models/webblen_gift_donation.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/content_gift_pool_data_service.dart';

class GiftDonationDataService {
  final CollectionReference giftDonationRef = FirebaseFirestore.instance.collection("webblen_content_gift_pools");
  final CollectionReference userRef = FirebaseFirestore.instance.collection("webblen_users");
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  ContentGiftPoolDataService _contentGiftPoolDataService = locator<ContentGiftPoolDataService>();

  Future<bool> sendGift({required String contentID, required String receiverUID, required String senderUID, required GiftDonation giftDonation}) async {
    bool sentGift = true;
    String? error;

    bool giftPoolExists = await _contentGiftPoolDataService.checkIfGiftPoolExists(contentID);

    if (!giftPoolExists) {
      WebblenContentGiftPool giftPool = WebblenContentGiftPool(id: contentID, hostID: receiverUID, gifters: {}, totalGiftAmount: 0, paidOut: false);
      await _contentGiftPoolDataService.createGiftPool(giftPool);
    }

    DocumentSnapshot snapshot = await userRef.doc(senderUID).get();
    double userWalletAmount = snapshot.data()!['WBLN'];
    if (giftDonation.giftAmount! > userWalletAmount) {
      _customDialogService.showErrorDialog(description: "Insufficient WBLN");
      sentGift = false;
    }

    userWalletAmount = userWalletAmount - giftDonation.giftAmount!;
    await userRef.doc(senderUID).update({"WBLN": userWalletAmount});

    await _contentGiftPoolDataService.addToGiftPool(giftPoolID: contentID, uid: senderUID, giftID: giftDonation.giftID, amount: giftDonation.giftAmount!);

    return sentGift;
  }

  Future<bool> updateGiftLog({
    required String contentID,
    required String senderUID,
    required String username,
    required String userImgURL,
    required GiftDonation giftDonation,
  }) async {
    bool updated = true;
    String? error;
    Map<dynamic, dynamic> donators = {};
    double giftPool;
    DocumentSnapshot snapshot = await giftDonationRef.doc(contentID).get();
    if (snapshot.exists && snapshot.data()!.isNotEmpty) {
      donators = snapshot.data()!['donators'];
      giftPool = snapshot.data()!['giftPool'] == null ? 0.0001 : snapshot.data()!['giftPool'];
      if (donators[senderUID] == null) {
        donators[senderUID] = {'uid': senderUID, 'username': username, 'userImgURL': userImgURL, 'totalGiftAmount': giftDonation.giftAmount};
      } else {
        Map<String, dynamic> donator = donators[senderUID];
        double prevGiftAmount = donator['totalGiftAmount'];
        double newGiftAmount = prevGiftAmount + giftDonation.giftAmount!;
        donators[senderUID] = {'uid': senderUID, 'username': username, 'userImgURL': userImgURL, 'totalGiftAmount': newGiftAmount};
      }
      giftPool += giftDonation.giftAmount!;
      await giftDonationRef.doc(contentID).update({'donators': donators, 'giftPool': giftPool});
    } else {
      donators[senderUID] = {'uid': senderUID, 'username': username, 'userImgURL': userImgURL, 'totalGiftAmount': giftDonation.giftAmount};
      giftPool = giftDonation.giftAmount!;
      await giftDonationRef.doc(contentID).set({'donators': donators, 'giftPool': giftPool});
    }
    return updated;
  }
}
