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

  Future<int> mintNft({
    required String creatorUid,
    required String assetName,
  }) async {
    int newAssetId = 0;
    int nftAmount = 100;
    // get user algorand account data
    final userAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(creatorUid);
    // TODO: Look into guaranteeing that a unique string is made every time
    final nftUnitName = getRandomString(8);
    print('pressed');
    // create NFT
    final nftMintresponse = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/nftMint'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': userAlgorandAccount.passphrase,
        'total_nfts_exist': nftAmount,
        'nft_unit_name': nftUnitName,
        'nft_asset_name': assetName,
      }),
    );

    if (nftMintresponse.statusCode == 200) {
      // Save transaction into collection
      Map<String, dynamic> result = jsonDecode(nftMintresponse.body);
      nftAmount = result['total_nfts_exist'];

      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['sender_address'],
      );
    } else {
      throw Exception(
        'Failed to mint nft. Status code: ${nftMintresponse.statusCode}',
      );
    }

    await Future.delayed(Duration(seconds: 10), () async {
      //Get asset id from newly created NFT
      final getAssetIdResponse = await http.post(
        Uri.parse(
            'https://us-central1-webblen-events.cloudfunctions.net/getAssetId'),
        body: jsonEncode(<String, dynamic>{
          'creator_address': userAlgorandAccount.address,
          'nft_unit_name': nftUnitName,
          'nft_asset_name': assetName,
        }),
      );

      if (getAssetIdResponse.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(getAssetIdResponse.body);
        print(result);
        newAssetId = result['nft_asset_id'];

        // Add asset id to user's asset id list
        final assetId = AssetId(assetId: newAssetId, amount: nftAmount);
        final userAssetIds = userAlgorandAccount.assetIds;
        userAssetIds?.add(assetId);

        // Update user's algorand account with newly updated asset id list
        await _userAlgorandAccountDataService.updateUserAlgorandAccountAssetIds(
          userAlgorandAccountId: userAlgorandAccount.id!,
          assetIds: userAssetIds!,
        );

        return newAssetId;
      } else {
        throw Exception(
          'Failed to create asset id. Status code: ${getAssetIdResponse.statusCode}',
        );
      }
    });
    return newAssetId;
  }

  Future<void> purchaseNft({
    required int assetId,
    required String userUid,
    required String businessUid,
    required int webblenPriceInMicroWebblen,
  }) async {
    // Get user algorand account data
    final UserAlgorandAccount userAlgorandAccount =
        await _userAlgorandAccountDataService
            .getUserAlgorandAccountByUID(userUid);

    final List<AssetId> userAssets = userAlgorandAccount.assetIds!;

    // If the user hasn't opted in to this nft before
    if (!userAssets.any((asset) => asset.assetId == assetId)) {
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
        throw Exception(
            'Failed to opt in to nft. Status code: ${nftOptInResponse.statusCode}');
      }
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
        // TODO: Use getWebblenAmountFromShopEntryPrice() when we have the exchange function
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
      throw Exception(
          'Failed to do nft atomic swap. Status code: ${nftWblnAtomicSwapResponse.statusCode}');
    }

    await updateUserAlgorandAccountAssets(
      userAlgorandAccount: businessAlgorandAccount,
      assetId: assetId,
    );

    await Future.delayed(Duration(seconds: 2), () async {
      await updateUserAlgorandAccountAssets(
        userAlgorandAccount: userAlgorandAccount,
        assetId: assetId,
      );
    });
  }

  Future<void> redeemNft({
    required int assetId,
    required String userUid,
    required String businessUid,
  }) async {
    final businessAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(businessUid);
    final userAlgorandAccount = await _userAlgorandAccountDataService
        .getUserAlgorandAccountByUID(userUid);

    final List<AssetId> userAssets = userAlgorandAccount.assetIds!;
    final AssetId userAssetId = userAssets.singleWhere(
      (aId) => aId.assetId == assetId,
      orElse: () => AssetId(assetId: 0, amount: 0),
    );

    // send NFT
    if (userAssetId.amount! > 0 && userAssetId.assetId != 0) {
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
        throw Exception(
            'Failed to send nft. Status code: ${response.statusCode}');
      }

      await Future.delayed(Duration(seconds: 2), () async {
        await updateUserAlgorandAccountAssets(
          userAlgorandAccount: businessAlgorandAccount,
          assetId: assetId,
        );
      });

      await Future.delayed(Duration(seconds: 2), () async {
        await updateUserAlgorandAccountAssets(
          userAlgorandAccount: userAlgorandAccount,
          assetId: assetId,
        );
      });
    } else {
      // TODO: DO SOMETHING ABOUT THIS CASE
      print('asset amount is 0 or doesnt exist');
    }
  }

  Future<void> updateUserAlgorandAccountAssets({
    required UserAlgorandAccount userAlgorandAccount,
    required int assetId,
  }) async {
    // Get user assetIndexer list
    final response = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/assetIndexer'),
      body: jsonEncode(<String, dynamic>{
        'address': userAlgorandAccount.address,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);

      // Example assetIndexerResult
      // {"account_assets":[{"amount":50000000000000000,"asset-id":15868631,"creator":"","deleted":false,"is-frozen":false,"opted-in-at-round":14193007}]}

      // Convert result into a list of maps
      final List assetIndexerResultList = result['account_assets'];
      print(assetIndexerResultList);
      // Get the map that has the relevant asset id
      final Map<String, dynamic> assetIndexerResultMap =
          assetIndexerResultList.singleWhere(
        (entry) => entry['asset-id'] == assetId,
      );

      // From the map, get the amount of the asset (NFT) they have
      final int amount = assetIndexerResultMap['amount'];

      final List<AssetId> assetIds = userAlgorandAccount.assetIds!;
      final AssetId newAssetId = AssetId(assetId: assetId, amount: amount);

      // if user doesn't have this asset in this asset list make a new
      if (!assetIds.any((asset) => asset.assetId == assetId)) {
        assetIds.add(newAssetId);
      } else {
        // Otherwise update amount from user's asset id list
        assetIds[assetIds.indexWhere(
          (assetIdEntry) => assetIdEntry.assetId == assetId,
        )] = newAssetId;
      }

      // update firestore doc
      await _userAlgorandAccountDataService.updateUserAlgorandAccountAssetIds(
        userAlgorandAccountId: userAlgorandAccount.id!,
        assetIds: assetIds,
      );
    } else {
      throw Exception(
          'Failed to get asset id. Status code: ${response.statusCode}');
    }
  }
}
