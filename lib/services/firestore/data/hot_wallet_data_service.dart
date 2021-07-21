import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'package:webblen/models/hot_wallet.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class HotWalletDataService {
  final CollectionReference hotWalletsRef =
      FirebaseFirestore.instance.collection("hot_wallets");

  Future<void> createHotWallet() async {
    final response = await http.get(Uri.parse(
        'https://us-central1-webblen-events.cloudfunctions.net/createAlgorandAccount'));

    if (response.statusCode == 200) {
      String id = getRandomString(30);
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> result = jsonDecode(response.body);
      print(result);
      final hotWallet = HotWallet(
        id: id,
        address: result['user_address'],
        passphrase: result['user_passphrase'],
        webblenAmount: 0,
        algoAmount: 0,
      );
      await hotWalletsRef.doc(id).set(hotWallet.toMap()).catchError((e) {
        return e.message;
      });
    } else {
      throw Exception('Failed to create hot wallet');
    }
  }

  Future<HotWallet> getMostWebblenFundedHotWallet() async {
    final hotWalletQuerySnapshot = await hotWalletsRef
        .orderBy('webblenAmount', descending: true)
        .limit(1)
        .get();

    final hotWalletDoc = hotWalletQuerySnapshot.docs[0].data()  as Map<String, dynamic>;

    final mostWebblenFundedHotWallet = HotWallet.fromMap(hotWalletDoc);

    return mostWebblenFundedHotWallet;
  }

  Future<HotWallet> getMostAlgoFundedHotWallet() async {
    final hotWalletQuerySnapshot = await hotWalletsRef
        .orderBy('algoAmount', descending: true)
        .limit(1)
        .get();

    final hotWalletDoc = hotWalletQuerySnapshot.docs[0].data() as Map<String, dynamic>;

    final mostAlgoFundedHotWallet = HotWallet.fromMap(hotWalletDoc);

    return mostAlgoFundedHotWallet;
  }
}
