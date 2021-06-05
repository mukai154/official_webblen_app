import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

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

  Future<void> createUserAlgorandAccount({required String uid}) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'createAlgorandAccount',
    );
    final HttpsCallableResult result = await callable.call().catchError((e) {
      print(e);
    });
    if (result.data != null) {
      final userAlgorandAccount = UserAlgorandAccount(
        id: getRandomString(30),
        uid: uid,
        address: result.data['user_address'],
        passphrase: result.data['user_passphrase'],
        webblenAmount: 0,
        algoAmount: 0,
        assetIds: [],
      );
      await userAlgorandAccountRef
          .doc()
          .set(userAlgorandAccount.toMap())
          .catchError((e) {
        return e.message;
      });
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

  Future updateUserAlgorandAccountAssetIds(
      {required String userAlgorandAccountId,
      required List<AssetId> assetIds}) async {
    await userAlgorandAccountRef
        .doc(userAlgorandAccountId)
        .update({'assetIds': assetIds}).catchError((e) {
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
      Map<String, dynamic> docData = doc.data()!;
      userAlgorandAccount = UserAlgorandAccount.fromMap(docData);
    }
    return userAlgorandAccount;
  }

  Future<void> sendAlgosToNewAccount(String uid) async {
    final hotWallet = await _hotWalletDataService.getMostAlgoFundedHotWallet();
    final userAlgorandAccount = await getUserAlgorandAccountByUID(uid);
    // Current this is hardcoded as 2,000,000 micro algos or 2 Algos for short
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendAlgosToNewAccount',
    );
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'sender_passphrase': hotWallet.passphrase,
      "receiver_address": userAlgorandAccount.address,
    }).catchError((e) {
      print(e);
    });
    if (result.data != null) {
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result.data['txid'],
        senderAlgorandAddress: result.data['sender_address'],
        receiverAlgorandAddress: result.data['receiver_address'],
      );
    }
  }

  Future<void> webblenOptIn(String uid) async {
    final userAlgorandAccount = await getUserAlgorandAccountByUID(uid);
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'wblnOptIn',
    );
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'sender_passphrase': userAlgorandAccount.passphrase,
    }).catchError((e) {
      print(e);
    });
    if (result.data != null) {
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result.data['txid'],
        senderAlgorandAddress: result.data['sender_address'],
        receiverAlgorandAddress: result.data['sender_address'],
      );
    }
  }

  Future<void> sendWebblenToNewAccount(String uid) async {
    final hotWallet =
        await _hotWalletDataService.getMostWebblenFundedHotWallet();
    final userAlgorandAccount = await getUserAlgorandAccountByUID(uid);
    // Current this is hardcoded as 5,000,000 micro webblen or 5 Webblen for short
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendWblnToNewAccount',
    );
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'sender_passphrase': hotWallet.passphrase,
      "receiver_address": userAlgorandAccount.address,
    }).catchError((e) {
      print(e);
    });
    if (result.data != null) {
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result.data['txid'],
        senderAlgorandAddress: result.data['sender_address'],
        receiverAlgorandAddress: result.data['receiver_address'],
      );
    }
  }

  Future<void> setUpUserAlgorandAccount(String uid) async {
    await createUserAlgorandAccount(uid: uid);
    await sendAlgosToNewAccount(uid);
    await webblenOptIn(uid);
    await sendWebblenToNewAccount(uid);
  }
}
