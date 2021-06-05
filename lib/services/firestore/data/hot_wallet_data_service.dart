import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/models/hot_wallet.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class HotWalletDataService {
  final CollectionReference hotWalletsRef =
      FirebaseFirestore.instance.collection("hot_wallets");

  Future<void> createHotWallet() async {
    String id = getRandomString(30);
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'createAlgorandAccount',
    );
    final HttpsCallableResult result = await callable.call();
    final hotWallet = HotWallet(
      id: id,
      address: result.data['user_address'],
      passphrase: result.data['user_passphrase'],
      webblenAmount: 0,
      algoAmount: 0,
    );
    await hotWalletsRef.doc(id).set(hotWallet.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future<HotWallet> getMostWebblenFundedHotWallet() async {
    final hotWalletQuerySnapshot = await hotWalletsRef
        .orderBy('webblenAmount', descending: true)
        .limit(1)
        .get();

    final hotWalletDoc = hotWalletQuerySnapshot.docs[0].data();

    final mostWebblenFundedHotWallet = HotWallet.fromMap(hotWalletDoc);

    return mostWebblenFundedHotWallet;
  }

  Future<HotWallet> getMostAlgoFundedHotWallet() async {
    final hotWalletQuerySnapshot = await hotWalletsRef
        .orderBy('algoAmount', descending: true)
        .limit(1)
        .get();

    final hotWalletDoc = hotWalletQuerySnapshot.docs[0].data();

    final mostAlgoFundedHotWallet = HotWallet.fromMap(hotWalletDoc);

    return mostAlgoFundedHotWallet;
  }
}
