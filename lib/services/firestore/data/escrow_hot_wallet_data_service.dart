import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:http/http.dart' as http;

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
    final response = await http.get(Uri.parse(
        'https://us-central1-webblen-events.cloudfunctions.net/createAlgorandAccount'));

    if (response.statusCode == 200) {
      String id = getRandomString(30);
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> result = jsonDecode(response.body);
      print(result);
      EscrowHotWallet newEscrowHotWallet = EscrowHotWallet(
        id: id,
        activeEventId: '',
        address: result['user_address'],
        passphrase: result['user_passphrase'],
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
    } else {
      throw Exception('Failed to create hot wallet');
    }
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
          EscrowHotWallet.fromMap(snapshot.docs[0].data() as Map<String, dynamic>);
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
    final escrowWalletResponse = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/sendWbln'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': userAlgorandAccount.passphrase,
        'receiver_address': availableEscrowHotWallet.address,
        'WBLN_amount': eventMicroWebblen,
      }),
    );

    if (escrowWalletResponse.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // Save transaction into collection
      Map<String, dynamic> result = jsonDecode(escrowWalletResponse.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['receiver_address'],
      );
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }

    // Fund cold storage wallet
    final coldStorageResponse = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/sendWbln'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': userAlgorandAccount.passphrase,
        // Cold storage address
        'receiver_address':
            'UXT53ITFZIIVS4MTG2UMCLX352N3YF5RZFEQA63VOO6CAYVZ3MZQ37QBVM',
        'WBLN_amount': coldStorageMicroWebblen,
      }),
    );

    if (coldStorageResponse.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // Save transaction into collection
      Map<String, dynamic> result = jsonDecode(coldStorageResponse.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['receiver_address'],
      );
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
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

    relevantEscrowHotWallet = EscrowHotWallet.fromMap(snapshot.docs[0].data() as Map<String, dynamic>);

    // Calculate webblen amounts for escrow wallet and cold storage
    final int eventMicroWebblen = (microWebblenAmount * 0.95).toInt();
    int coldStorageMicroWebblen = (microWebblenAmount * 0.05).toInt();
    final int remainderMicroWebblen =
        microWebblenAmount - (eventMicroWebblen + coldStorageMicroWebblen);
    coldStorageMicroWebblen += remainderMicroWebblen;

    // Fund escrow wallet
    final escrowWalletResponse = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/sendWbln'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': userAlgorandAccount.passphrase,
        'receiver_address': relevantEscrowHotWallet.address,
        'WBLN_amount': eventMicroWebblen,
      }),
    );

    if (escrowWalletResponse.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // Save transaction into collection
      Map<String, dynamic> result = jsonDecode(escrowWalletResponse.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['receiver_address'],
      );
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }

    // Fund cold storage wallet
    final coldStorageResponse = await http.post(
      Uri.parse(
          'https://us-central1-webblen-events.cloudfunctions.net/sendWbln'),
      body: jsonEncode(<String, dynamic>{
        'sender_passphrase': userAlgorandAccount.passphrase,
        // Cold storage address
        'receiver_address':
            'UXT53ITFZIIVS4MTG2UMCLX352N3YF5RZFEQA63VOO6CAYVZ3MZQ37QBVM',
        'WBLN_amount': coldStorageMicroWebblen,
      }),
    );

    if (coldStorageResponse.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // Save transaction into collection
      Map<String, dynamic> result = jsonDecode(coldStorageResponse.body);
      await _algorandTransactionDataService.saveAlgorandTransaction(
        txid: result['txid'],
        senderAlgorandAddress: result['sender_address'],
        receiverAlgorandAddress: result['receiver_address'],
      );
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }
}
