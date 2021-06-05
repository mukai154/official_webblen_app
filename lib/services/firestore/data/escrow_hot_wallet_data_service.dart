import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/app/app.locator.dart';

import 'package:webblen/models/escrow_hot_wallet.dart';
import 'package:webblen/services/firestore/data/algorand_transaction_data_service.dart';
import 'package:webblen/services/firestore/data/user_algorand_account_data.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class EscrowHotWalletDataService {
  final CollectionReference escrowHotWalletsRef =
      FirebaseFirestore.instance.collection("escrow_hot_wallets");
  UserAlgorandAccountDataService _userAlgorandAccountDataService =
      locator<UserAlgorandAccountDataService>();
  AlgorandTransactionDataService _algorandTransactionDataService =
      locator<AlgorandTransactionDataService>();

  Future<EscrowHotWallet> createEscrowWallet() async {
    String id = getRandomString(30);

    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'createAlgorandAccount',
    );
    final HttpsCallableResult result = await callable.call().catchError((e) {
      return e.message;
    });

    EscrowHotWallet newEscrowHotWallet = EscrowHotWallet(
      id: id,
      activeEventId: '',
      address: result.data['user_address'],
      passphrase: result.data['user_passphrase'],
      webblenAmount: 0,
      algoAmount: 0,
    );

    await escrowHotWalletsRef
        .doc(id)
        .set(newEscrowHotWallet.toMap())
        .catchError((e) {
      return e.message;
    });

    return newEscrowHotWallet;
  }

  Future<void> create100EscrowWallets() async {
    for (var i = 0; i < 100; i++) {
      await createEscrowWallet();
    }
  }

  Future updateEscrowHotWalletActiveEventId({
    required String id,
    required String activeEventId,
  }) async {
    await escrowHotWalletsRef
        .doc(id)
        .update({'activeEventId': activeEventId}).catchError((e) {
      return e.message;
    });
  }

  // TODO: When deleting an event before it occurs, also delete relevant escrow wallet when applicable
  Future<void> fundEscrowHotWallet({
    required String uid,
    required String eventId,
    required int microWebblenAmount,
  }) async {
    final userAlgorandAccount =
        await _userAlgorandAccountDataService.getUserAlgorandAccountByUID(uid);
    final EscrowHotWallet availableEscrowHotWallet;

    // Find an available escrow wallet
    final snapshot = await escrowHotWalletsRef
        .where('activeEventId', isEqualTo: '')
        .limit(1)
        .get();

    // Create escrow wallet if none are currently available and update activeEventId
    if (snapshot.docs.isEmpty) {
      availableEscrowHotWallet = await createEscrowWallet();
      await updateEscrowHotWalletActiveEventId(
        id: availableEscrowHotWallet.id!,
        activeEventId: eventId,
      );
    } else {
      availableEscrowHotWallet =
          EscrowHotWallet.fromMap(snapshot.docs[0].data());
      await updateEscrowHotWalletActiveEventId(
        id: availableEscrowHotWallet.id!,
        activeEventId: eventId,
      );
    }

    // Calculate webblen amounts for escrow wallet and cold storage
    final int eventMicroWebblen = (microWebblenAmount * 0.95).toInt();
    int coldStorageMicroWebblen = (microWebblenAmount * 0.05).toInt();
    final int remainderMicroWebblen =
        microWebblenAmount - (eventMicroWebblen + coldStorageMicroWebblen);
    coldStorageMicroWebblen += remainderMicroWebblen;

    // Fund escrow wallet
    final HttpsCallable webblenForEvent =
        FirebaseFunctions.instance.httpsCallable(
      'sendWbln',
    );
    final HttpsCallableResult webblenForEventResult =
        await webblenForEvent.call(<String, dynamic>{
      'sender_passphrase': userAlgorandAccount.passphrase,
      'receiver_address': availableEscrowHotWallet.address,
      'WBLN_amount': eventMicroWebblen,
    }).catchError((e) {
      print(e);
    });
    // Save transaction into collection
    await _algorandTransactionDataService.saveAlgorandTransaction(
      txid: webblenForEventResult.data['txid'],
      senderAlgorandAddress: webblenForEventResult.data['sender_address'],
      receiverAlgorandAddress: webblenForEventResult.data['receiver_address'],
    );

    // Fund cold storage
    final HttpsCallable webblenForColdStorage =
        FirebaseFunctions.instance.httpsCallable(
      'sendWbln',
    );
    final HttpsCallableResult webblenForColdStorageResult =
        await webblenForColdStorage.call(<String, dynamic>{
      'sender_passphrase': userAlgorandAccount.passphrase,
      // Cold storage address
      'receiver_address':
          'UXT53ITFZIIVS4MTG2UMCLX352N3YF5RZFEQA63VOO6CAYVZ3MZQ37QBVM',
      'WBLN_amount': coldStorageMicroWebblen,
    }).catchError((e) {
      print(e);
    });
    // Save transaction into collection
    await _algorandTransactionDataService.saveAlgorandTransaction(
      txid: webblenForColdStorageResult.data['txid'],
      senderAlgorandAddress: webblenForColdStorageResult.data['sender_address'],
      receiverAlgorandAddress:
          webblenForColdStorageResult.data['receiver_address'],
    );
  }

  Future<void> increaseEscrowHotWalletFund({
    required String uid,
    required String eventId,
    required int microWebblenAmount,
  }) async {
    final userAlgorandAccount =
        await _userAlgorandAccountDataService.getUserAlgorandAccountByUID(uid);
    final EscrowHotWallet relevantEscrowHotWallet;

    // Find relevant escrow wallet
    final snapshot = await escrowHotWalletsRef
        .where('activeEventId', isEqualTo: 'eventId')
        .get()
        .catchError((e) {
      print(e);
    });

    relevantEscrowHotWallet = EscrowHotWallet.fromMap(snapshot.docs[0].data());

    // Calculate webblen amounts for escrow wallet and cold storage
    final int eventMicroWebblen = (microWebblenAmount * 0.95).toInt();
    int coldStorageMicroWebblen = (microWebblenAmount * 0.05).toInt();
    final int remainderMicroWebblen =
        microWebblenAmount - (eventMicroWebblen + coldStorageMicroWebblen);
    coldStorageMicroWebblen += remainderMicroWebblen;

    // Fund escrow wallet
    final HttpsCallable webblenForEvent =
        FirebaseFunctions.instance.httpsCallable(
      'sendWbln',
    );
    final HttpsCallableResult webblenForEventResult =
        await webblenForEvent.call(<String, dynamic>{
      'sender_passphrase': userAlgorandAccount.passphrase,
      'receiver_address': relevantEscrowHotWallet.address,
      'WBLN_amount': eventMicroWebblen,
    }).catchError((e) {
      print(e);
    });
    // Save transaction into collection
    await _algorandTransactionDataService.saveAlgorandTransaction(
      txid: webblenForEventResult.data['txid'],
      senderAlgorandAddress: webblenForEventResult.data['sender_address'],
      receiverAlgorandAddress: webblenForEventResult.data['receiver_address'],
    );

    // Fund cold storage
    final HttpsCallable webblenForColdStorage =
        FirebaseFunctions.instance.httpsCallable(
      'sendWbln',
    );
    final HttpsCallableResult webblenForColdStorageResult =
        await webblenForColdStorage.call(<String, dynamic>{
      'sender_passphrase': userAlgorandAccount.passphrase,
      // Cold storage address
      'receiver_address':
          'UXT53ITFZIIVS4MTG2UMCLX352N3YF5RZFEQA63VOO6CAYVZ3MZQ37QBVM',
      'WBLN_amount': coldStorageMicroWebblen,
    }).catchError((e) {
      print(e);
    });
    // Save transaction into collection
    await _algorandTransactionDataService.saveAlgorandTransaction(
      txid: webblenForColdStorageResult.data['txid'],
      senderAlgorandAddress: webblenForColdStorageResult.data['sender_address'],
      receiverAlgorandAddress:
          webblenForColdStorageResult.data['receiver_address'],
    );
  }
}
