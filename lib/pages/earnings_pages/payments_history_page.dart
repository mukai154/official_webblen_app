import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/utils/time_calc.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class PaymentHistoryPage extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  CollectionReference stripeRef = FirebaseFirestore.instance.collection("stripe");
  CollectionReference stripeActivityRef = FirebaseFirestore.instance.collection("stripe_connect_activity");

  String currentUID;
  List<DocumentSnapshot> paymentHistoryResults = [];
  DocumentSnapshot lastDocumentSnapshot;
  int resultsPerPage = 10;
  bool isLoading = true;
  bool loadingAdditionalData = false;
  bool moreDataAvailable = true;

  ScrollController scrollController = ScrollController();

  getPaymentHistory() async {
    Query paymentsHistoryQuery = stripeActivityRef.where("uid", isEqualTo: currentUID).orderBy("timePosted", descending: true).limit(resultsPerPage);
    QuerySnapshot querySnapshot = await paymentsHistoryQuery.get();
    lastDocumentSnapshot = querySnapshot.docs[querySnapshot.docs.length - 1];
    paymentHistoryResults = querySnapshot.docs;
    isLoading = false;
    setState(() {});
  }

  getAdditionalPaymentHistory() async {
    if (isLoading || !moreDataAvailable || loadingAdditionalData) {
      return;
    }
    loadingAdditionalData = true;
    setState(() {});
    Query paymentsHistoryQuery = stripeActivityRef
        .where("uid", isEqualTo: currentUID)
        .orderBy("timePosted", descending: true)
        .startAfterDocument(lastDocumentSnapshot)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await paymentsHistoryQuery.get();
    lastDocumentSnapshot = querySnapshot.docs[querySnapshot.docs.length - 1];
    paymentHistoryResults.addAll(querySnapshot.docs);
    if (querySnapshot.docs.length == 0) {
      moreDataAvailable = false;
    }
    loadingAdditionalData = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BaseAuth().getCurrentUserID().then((res) {
      currentUID = res;
      setState(() {});
      getPaymentHistory();
    });
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if (maxScroll - currentScroll < delta) {
        getAdditionalPaymentHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar(
        'Payments History',
        context,
      ),
      body: ListView(
        children: <Widget>[
          isLoading ? CustomLinearProgress(progressBarColor: CustomColors.webblenRed) : Container(),
          SizedBox(height: 16.0),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.0),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 32,
            ),
            child: ListView.builder(
              controller: scrollController,
              shrinkWrap: true,
              itemCount: paymentHistoryResults.length,
              itemBuilder: (_, int index) {
                final Map<String, dynamic> docData = paymentHistoryResults[index].data();
                final dynamic message = docData['description'];
                final dynamic timePosted = docData['timePosted'];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: CustomText(
                      context: context,
                      text: message,
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                    subtitle: CustomText(
                      context: context,
                      text: TimeCalc().getPastTimeFromMilliseconds(timePosted),
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 32.0),
        ],
      ),
    );
  }
}
