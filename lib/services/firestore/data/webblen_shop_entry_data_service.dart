import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_shop_entry.dart';
import 'package:webblen/services/nft/nft_service.dart';

class WebblenShopEntryDataService {
  final CollectionReference webblenShopEntriesRef =
      FirebaseFirestore.instance.collection("webblen_shop_entries");
  NftService _nftService = locator<NftService>();

  Future createWebblenShopEntry({
    required String uid,
    required String title,
    required String description,
    required double price,
    required String transactionCurrency,
  }) async {
    // Mint NFT and return the newly created asset id
    final newAssetId = await _nftService.mintNft(creatorUid: uid);

    // Add item to shop collection with the asset id and user shop input
    final webblenShopEntry = WebblenShopEntry(
      assetId: newAssetId,
      creatorUid: uid,
      title: title,
      description: description,
      price: price,
      transactionCurrency: transactionCurrency,
      creationTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    await webblenShopEntriesRef
        .doc(webblenShopEntry.assetId.toString())
        .set(webblenShopEntry.toMap())
        .catchError((e) {
      return e.message;
    });
  }

  // int getMicroWebblenAmountFromShopEntryPrice(WebblenShopEntry webblenShopEntry) {
  //   final int priceInWebblen;
  //   if (webblenShopEntry.transactionCurrency == 'WBLN') {
  //     priceInWebblen = (webblenShopEntry.price! * 1000000).toInt();
  //     return priceInWebblen;
  //   } else {
  //     priceInWebblen = (convertUSDIntoMicroWebblen(webblenShopEntry.price!) * 1000000).toInt();
  //     return priceInWebblen;
  //   }
  // }

  Future<void> purchaseShopEntry(
      {required WebblenShopEntry webblenShopEntry, required String uid}) async {
    await _nftService.purchaseNft(
      assetId: webblenShopEntry.assetId!,
      userUid: uid,
      businessUid: webblenShopEntry.creatorUid!,
      // TODO: use getMicroWebblenAmountFromShopEntryPrice() to get price if not in webblen (right above)
      // webblenPriceInMicroWebblen: getMicroWebblenAmountFromShopEntryPrice(webblenShopEntry.price!),
      webblenPriceInMicroWebblen: 1000000,
    );
  }

  Future<void> redeemShopEntryNft({
    required WebblenShopEntry webblenShopEntry,
    required String userUid,
  }) async {
    await _nftService.redeemNft(
      assetId: webblenShopEntry.assetId!,
      userUid: userUid,
      businessUid: webblenShopEntry.creatorUid!,
    );
  }
}
