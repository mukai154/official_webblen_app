import 'package:webblen/enums/transaction_currency.dart';
import 'package:webblen/enums/transaction_type.dart';

class WebblenTransaction {
  String receiverUID;
  String senderUID;
  String eventID;
  String streamID;
  TransactionType type;
  TransactionCurrency currency;
  String header;
  String subHeader;
  Map<dynamic, dynamic> additionalData;
  int timePostedInMilliseconds;
  bool read;

  WebblenTransaction({
    this.receiverUID,
    this.senderUID,
    this.eventID,
    this.streamID,
    this.type,
    this.currency,
    this.header,
    this.subHeader,
    this.additionalData,
    this.timePostedInMilliseconds,
    this.read,
  });

  WebblenTransaction.fromMap(Map<String, dynamic> data)
      : this(
          receiverUID: data['receiverUID'],
          senderUID: data['senderUID'],
          eventID: data['eventID'],
          streamID: data['streamID'],
          type: TransactionTypeConverter.stringToTransactionType(data['type']),
          currency: TransactionCurrencyConverter.stringToTransactionCurrency(
              data['currency']),
          header: data['header'],
          subHeader: data['subHeader'],
          additionalData: data['additionalData'],
          timePostedInMilliseconds: data['timePostedInMilliseconds'],
          read: data['read'],
        );

  Map<String, dynamic> toMap() => {
        'receiverUID': this.receiverUID,
        'senderUID': this.senderUID,
        'eventID': this.eventID,
        'streamID': this.streamID,
        'type': TransactionTypeConverter.transactionTypeToString(this.type),
        'currency': TransactionCurrencyConverter.transactionCurrencyToString(
            this.currency),
        'header': this.header,
        'subHeader': this.subHeader,
        'additionalData': this.additionalData,
        'timePostedInMilliseconds': this.timePostedInMilliseconds,
        'read': this.read,
      };

  //
  // //Webblen Received Notification
  // WebblenNotification generateWebblenReceivedNotification({
  //   @required String postID,
  //   @required String receiverUID,
  //   @required String senderUID,
  //   @required String senderUsername,
  //   @required String amountReceived,
  // }) {
  //   WebblenNotification notif = WebblenNotification(
  //     receiverUID: receiverUID,
  //     senderUID: senderUID,
  //     type: NotificationType.webblenReceived,
  //     header: '$senderUsername sent you WBLN',
  //     subHeader: '$amountReceived WBLN has been deposited in your wallet',
  //     additionalData: {'postID': postID},
  //     timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
  //     expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
  //     read: false,
  //   );
  //   return notif;
  // }
}
