import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/user_algorand_account.dart';
import 'package:webblen/services/firestore/data/algorand_transaction_data_service.dart';
import 'package:webblen/services/firestore/data/user_algorand_account_data.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class NftService {
  UserAlgorandAccountDataService _userAlgorandAccountDataService =
      locator<UserAlgorandAccountDataService>();
  AlgorandTransactionDataService _algorandTransactionDataService =
      locator<AlgorandTransactionDataService>();

  Future<int> mintNft({required creatorUid, required assetName}) async {
    // get user algorand account data
    final userAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(creatorUid);
    // TODO: Look into guaranteeing that a unique string is made every time
    final nftUnitName = getRandomString(30);

    // create NFT
    final nftMintresponse = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/nftMint'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': userAlgorandAccount.passphrase,
        'total_nfts_exist': 100,
        'nft_unit_name': nftUnitName,
        'nft_asset_name': assetName,
      }),
    );

    if (nftMintresponse.statusCode == 200) {
      // Save transaction into collection
      Map<String, dynamic> result = jsonDecode(nftMintresponse.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['sender_address'],
      );
    } else {
      throw Exception('Failed to save transaction');
    }

    // Get asset id from newly created NFT
    final getAssetIdResponse = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/getAssetId'),
      body: jsonEncode(<String, dynamic>{
        'creator_address': userAlgorandAccount.passphrase,
        'nft_unit_name': nftUnitName,
        'nft_asset_name': assetName,
      }),
    );

    if (getAssetIdResponse.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(getAssetIdResponse.body);
      final int newAssetId = result['nft_asset_id'];

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
    } else {
      throw Exception('Failed to create asset id');
    }
  }

  Future purchaseNft({
    required int assetId,
    required String userUid,
    required String businessUid,
    required int webblenPriceInMicroWebblen,
  }) async {
    // get user algorand account data
    final userAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(userUid);

    final nftOptInResponse = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/nftOptIn'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': userAlgorandAccount.passphrase,
        'nft_asset_id': assetId,
      }),
    );

    if (nftOptInResponse.statusCode == 200) {
      // Save transaction into collection
      Map<String, dynamic> result = jsonDecode(nftOptInResponse.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['sender_address'],
      );
    } else {
      throw Exception('Failed to save transaction');
    }

    // Get business algorand account data
    final businessAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(businessUid);

    // Perform atomic swap to transfer webblen from the buyer's account into the seller's
    final nftWblnAtomicSwapResponse = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/nftWblnAtomicSwap'),
      body: jsonEncode(<String, dynamic>{
        'user_passphrase': userAlgorandAccount.passphrase,
        'business_passphrase': businessAlgorandAccount.passphrase,
        'business_nft_asset_id': assetId,
        // Use getWebblenAmountFromShopEntryPrice() when we have the exchange function
        'WBLN_amount': webblenPriceInMicroWebblen,
      }),
    );

    if (nftWblnAtomicSwapResponse.statusCode == 200) {
      // Save transaction into collection
      Map<String, dynamic> result = jsonDecode(nftWblnAtomicSwapResponse.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['user_address'],
        receiverAlgorandAddress: result['business_address'],
      );
    } else {
      throw Exception('Failed to save transaction');
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
    final response = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/sendNft'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': userAlgorandAccount.passphrase,
        'receiver_address': businessAlgorandAccount.address,
        'nft_asset_id': assetId,
      }),
    );

    if (response.statusCode == 200) {
      // Save transaction into collection
      Map<String, dynamic> result = jsonDecode(response.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['receiver_address'],
      );
    } else {
      throw Exception('Failed to save transaction');
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

  Future updateUserAlgorandAccountAssets({
    required UserAlgorandAccount userAlgorandAccount,
    required int assetId,
  }) async {
    // Get user assetIndexer list
    final response = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/assetIndexer'),
      body: jsonEncode(<String, dynamic>{
        'address': userAlgorandAccount.passphrase,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);

      // Example assetIndexerResult
      // {"account_assets":[{"amount":50000000000000000,"asset-id":15868631,"creator":"","deleted":false,"is-frozen":false,"opted-in-at-round":14193007}]}

      // Convert result into a list of maps
      final List<Map<String, dynamic>> assetIndexerResultList =
          result['account_assets'];
      // Get the map that has the relevant asset id
      final Map<String, dynamic> assetIndexerResultMap =
          assetIndexerResultList.singleWhere(
        (entry) => entry['asset-id'] == assetId,
      );

      // From the map, get the amount of the asset (NFT) they have
      final int amount = assetIndexerResultMap['amount'];

      List<AssetId> assetIds = userAlgorandAccount.assetIds!;

      // Updates amount from user's asset id list then update doc
      assetIds[assetIds.indexWhere(
        (assetIdEntry) => assetIdEntry.assetId == assetId,
      )] = AssetId(assetId: assetId, amount: amount);

      await _userAlgorandAccountDataService.updateUserAlgorandAccountAssetIds(
        userAlgorandAccountId: userAlgorandAccount.id!,
        assetIds: assetIds,
      );
    } else {
      throw Exception('Failed to create asset id');
    }
  }
}
