import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class EmailService {
  CollectionReference stripeRef = FirebaseFirestore.instance.collection("stripe");

  Future<void> sendTicketPurchaseConfirmationEmail({
    required String emailAddress,
    required String eventTitle,
    required List purchasedTickets,
    required String additionalTaxesAndFees,
    required String discountCodeDescription,
    required String discountValue,
    required String totalCharge,
  }) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendTicketPurchaseConfirmationEmail',
    );

    callable.call(
      <String, dynamic>{
        'emailAddress': emailAddress,
        'eventTitle': eventTitle,
        'purchasedTickets': purchasedTickets,
        'additionalTaxesAndFees': additionalTaxesAndFees,
        'discountCodeDescription': discountCodeDescription,
        'discountValue': discountValue,
        'totalCharge': totalCharge,
      },
    );
  }
}
