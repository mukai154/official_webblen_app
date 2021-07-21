import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/user_algorand_account.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/algorand_transaction_data_service.dart';
import 'package:webblen/services/firestore/data/hot_wallet_data_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class UserAlgorandAccountDataService {
  final CollectionReference userAlgorandAccountRef =
      FirebaseFirestore.instance.collection("user_algorand_accounts");
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  AlgorandTransactionDataService _algorandTransactionDataService =
      locator<AlgorandTransactionDataService>();
  HotWalletDataService _hotWalletDataService = locator<HotWalletDataService>();

  Future<void> createUserAlgorandAccount(String uid) async {
    final response = await http.get(Uri.parse(
        'https://us-central1-webblen-events.cloudfunctions.net/createAlgorandAccount'));

    if (response.statusCode == 200) {
      String id = getRandomString(30);
      Map<String, dynamic> result = jsonDecode(response.body);
      final userAlgorandAccount = UserAlgorandAccount(
        id: id,
        uid: uid,
        address: result['user_address'],
        passphrase: result['user_passphrase'],
        webblenAmount: 0,
        algoAmount: 0,
        assetIds: [],
      );
      await userAlgorandAccountRef
          .doc(id)
          .set(userAlgorandAccount.toMap())
          .catchError((e) {
        return e.message;
      });
    } else {
      throw Exception('Failed to create hot wallet');
    }
  }

  Future updateUserAlgorandAccount(
      {required UserAlgorandAccount userAlgorandAccount}) async {
    await userAlgorandAccountRef
        .doc(userAlgorandAccount.id)
        .update(userAlgorandAccount.toMap())
        .catchError((e) {
      return e.message;
    });
  }

  Future updateUserAlgorandAccountAssetIds({
    required String userAlgorandAccountId,
    required List<AssetId> assetIds,
  }) async {
    await userAlgorandAccountRef.doc(userAlgorandAccountId).update({
      'assetIds': assetIds.map((assetId) => assetId.toMap()).toList(),
    }).catchError((e) {
      return e.message;
    });
  }

  Future<UserAlgorandAccount> getUserAlgorandAccountByUID(String uid) async {
    UserAlgorandAccount userAlgorandAccount = UserAlgorandAccount();
    String? error;
    QuerySnapshot querySnapshot = await userAlgorandAccountRef
        .where("uid", isEqualTo: uid)
        .get()
        .catchError((e) {
      error = e.message;
    });
    if (error != null) {
      _customDialogService.showErrorDialog(description: error!);
      return userAlgorandAccount;
    }
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      Map<String, dynamic> docData = doc.data()! as Map<String, dynamic>;
      userAlgorandAccount = UserAlgorandAccount.fromMap(docData);
    }
    return userAlgorandAccount;
  }

  Future<void> sendAlgosToNewAccount(String uid) async {
    final hotWallet = await _hotWalletDataService.getMostAlgoFundedHotWallet();
    final userAlgorandAccount = await getUserAlgorandAccountByUID(uid);

    print('most funded algo wallet id: ${hotWallet.id}');

    // Currently this is hardcoded as 2,000,000 micro algos or 2 Algos for short
    final response = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/sendAlgosToNewAccount'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': hotWallet.passphrase,
        'receiver_address': userAlgorandAccount.address,
      }),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);

      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['receiver_address'],
      );
    } else {
      throw Exception(
          'sendAlgosToNewAccount failed. Status code: ${response.statusCode}');
    }
  }

  Future<void> webblenOptIn(String uid) async {
    final userAlgorandAccount = await getUserAlgorandAccountByUID(uid);

    final response = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/wblnOptIn'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': userAlgorandAccount.passphrase,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: '',
        receiverAlgorandAddress: '',
      );
    } else {
      throw Exception(
          'webblenOptIn failed. Status code: ${response.statusCode}');
    }
  }

  Future<void> sendWebblenToNewAccount(String uid) async {
    final hotWallet =
        await _hotWalletDataService.getMostWebblenFundedHotWallet();
    final userAlgorandAccount = await getUserAlgorandAccountByUID(uid);

    print('most funded webblen wallet id: ${hotWallet.id}');

    // Current this is hardcoded as 5,000,000 micro webblen or 5 Webblen for short
    final response = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/sendWblnToNewAccount'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': hotWallet.passphrase,
        'receiver_address': userAlgorandAccount.address,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['receiver_address'],
      );
    } else {
      throw Exception(
          'sendWebblenToNewAccount failed. Status code: ${response.statusCode}');
    }
  }

  Future<void> setUpUserAlgorandAccount(String uid) async {
    await createUserAlgorandAccount(uid);
    await sendAlgosToNewAccount(uid);
    await webblenOptIn(uid);
    await sendWebblenToNewAccount(uid);
  }
}
