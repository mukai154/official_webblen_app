import 'package:cloud_functions/cloud_functions.dart';

import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/user_algorand_account.dart';
import 'package:webblen/services/firestore/data/algorand_transaction_data_service.dart';
import 'package:webblen/services/firestore/data/user_algorand_account_data.dart';

class NftService {
  UserAlgorandAccountDataService _userAlgorandAccountDataService =
      locator<UserAlgorandAccountDataService>();
  AlgorandTransactionDataService _algorandTransactionDataService =
      locator<AlgorandTransactionDataService>();

  Future<int> mintNft({required creatorUid}) async {
    // get user algorand account data
    final userAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(creatorUid);

    // create NFT
    final HttpsCallable nftMint = FirebaseFunctions.instance.httpsCallable(
      'nftMint',
    );
    final HttpsCallableResult nftMintResult = await nftMint.call({
      'sender_passphrase': userAlgorandAccount.passphrase,
      'total_nfts_exist': 100,
      'nft_unit_name': 'WBLN',
      'nft_asset_name': 'Webblen Token',
    });
    if (nftMintResult.data != null) {
      // Save NFT transaction into collection
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: nftMintResult.data['txid'],
        senderAlgorandAddress: nftMintResult.data['sender_address'],
        receiverAlgorandAddress: '',
      );
    }

    // Get asset id from newly created NFT
    final HttpsCallable getAssetId = FirebaseFunctions.instance.httpsCallable(
      'getAssetId',
    );
    final HttpsCallableResult getAssetIdResult = await getAssetId.call({
      'creator_address': userAlgorandAccount.passphrase,
      'nft_unit_name': 'WBLN',
      'nft_asset_name': 'Webblen Token',
    });

    final int newAssetId = getAssetIdResult.data['nft_asset_id'];

    // Add asset id to user's asset id list
    final assetId = AssetId(assetId: newAssetId, amount: 100);
    final userAssetIds = userAlgorandAccount.assetIds;
    userAssetIds?.add(assetId);

    // Update user's algorand account with newly updated asset id list
    await _userAlgorandAccountDataService.updateUserAlgorandAccountAssetIds(
      userAlgorandAccountId: userAlgorandAccount.id!,
      assetIds: userAssetIds!,
    );

    return newAssetId;
  }

  Future purchaseNft(
      {required int assetId,
      required String userUid,
      required String businessUid,
      required int webblenPriceInMicroWebblen}) async {
    // get user algorand account data
    final userAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(userUid);
    // Perform NFT opt in
    final HttpsCallable nftOptIn = FirebaseFunctions.instance.httpsCallable(
      'nftOptIn',
    );
    final HttpsCallableResult nftOptInResult = await nftOptIn.call({
      'sender_passphrase': userAlgorandAccount.passphrase,
      'nft_asset_id': assetId,
    });
    if (nftOptInResult.data != null) {
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: nftOptInResult.data['txid'],
        senderAlgorandAddress: nftOptInResult.data['sender_address'],
        receiverAlgorandAddress: '',
      );
    }

    // Get business algorand account data
    final businessAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(businessUid);
    // Perform atomic swap to transfer webblen from the buyer's account into the seller's
    final HttpsCallable nftWblnAtomicSwap =
        FirebaseFunctions.instance.httpsCallable(
      'nftWblnAtomicSwap',
    );
    final HttpsCallableResult nftWblnAtomicSwapResult =
        await nftWblnAtomicSwap.call({
      'user_passphrase': userAlgorandAccount.passphrase,
      'business_passphrase': businessAlgorandAccount.passphrase,
      'business_nft_asset_id': assetId,
      // Use getWebblenAmountFromShopEntryPrice() when we have the exchange function
      'WBLN_amount': webblenPriceInMicroWebblen,
    });
    if (nftWblnAtomicSwapResult.data != null) {
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: nftWblnAtomicSwapResult.data['txid'],
        senderAlgorandAddress: nftWblnAtomicSwapResult.data['user_address'],
        receiverAlgorandAddress:
            nftWblnAtomicSwapResult.data['business_address'],
      );
    }

    await updateUserAlgorandAccountAssets(
      userAlgorandAccount: businessAlgorandAccount,
      assetId: assetId,
    );
    await updateUserAlgorandAccountAssets(
      userAlgorandAccount: userAlgorandAccount,
      assetId: assetId,
    );
  }

  Future redeemNft({
    required int assetId,
    required String userUid,
    required String businessUid,
  }) async {
    final businessAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(businessUid);
    final userAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(userUid);
    // send NFT
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendNft',
    );
    final HttpsCallableResult result = await callable.call({
      'sender_passphrase': businessAlgorandAccount.passphrase,
      'receiver_address': userAlgorandAccount.address,
      'nft_asset_id': assetId,
    });
    if (result.data != null) {
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result.data['txid'],
        senderAlgorandAddress: result.data['sender_address'],
        receiverAlgorandAddress: result.data['receiver_address'],
      );
    }

    await updateUserAlgorandAccountAssets(
      userAlgorandAccount: businessAlgorandAccount,
      assetId: assetId,
    );
    await updateUserAlgorandAccountAssets(
      userAlgorandAccount: userAlgorandAccount,
      assetId: assetId,
    );
  }

  Future updateUserAlgorandAccountAssets(
      {required UserAlgorandAccount userAlgorandAccount,
      required int assetId}) async {
    // Get user assetIndexer list
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'assetIndexer',
    );
    final HttpsCallableResult result = await callable.call({
      'address': userAlgorandAccount.passphrase,
    });

    // Example assetIndexerResult
    // {"account_assets":[{"amount":50000000000000000,"asset-id":15868631,"creator":"","deleted":false,"is-frozen":false,"opted-in-at-round":14193007}]}

    // Convert result into a list of maps
    final List<Map<String, dynamic>> assetIndexerResultList =
        result.data['account_assets'];
    // Get the map that has the relevant asset id
    final Map<String, dynamic> assetIndexerResultMap =
        assetIndexerResultList.firstWhere(
      (entry) => entry['asset-id'] == assetId,
    );

    // From the map, get the amount of the asset (NFT) they have
    final int amount = assetIndexerResultMap['amount'];

    // Updates amount from user's asset id list then update doc
    final assetIds = userAlgorandAccount.assetIds;
    assetIds?.removeWhere(
      (assetIdEntry) => assetIdEntry.assetId == assetId,
    );
    assetIds?.add(
      AssetId(assetId: assetId, amount: amount),
    );
    await _userAlgorandAccountDataService.updateUserAlgorandAccountAssetIds(
      userAlgorandAccountId: userAlgorandAccount.id!,
      assetIds: assetIds!,
    );
  }
}
