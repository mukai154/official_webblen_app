import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/pages/shop_pages/shop_page.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/rewards/redeemed_reward_block.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class RedeemedRewardsPage extends StatefulWidget {
  final WebblenUser currentUser;
  RedeemedRewardsPage({this.currentUser});
  @override
  _RedeemedRewardsPageState createState() => _RedeemedRewardsPageState();
}

class _RedeemedRewardsPageState extends State<RedeemedRewardsPage> {
  bool isLoading = true;
  ScrollController scrollController;
  List<DocumentSnapshot> results = [];
  DocumentSnapshot lastDocSnap;
  bool loadingAdditionalData = false;
  bool moreDataAvailable = true;
  CollectionReference ref = FirebaseFirestore.instance.collection("purchased_rewards");

  Future<void> refreshData() async {
    results = [];
    setState(() {});
    loadData();
  }

  loadData() async {
    QuerySnapshot querySnapshot =
        await ref.where('uid', isEqualTo: widget.currentUser.uid).orderBy('purchaseTimeInMilliseconds', descending: true).get().catchError((e) {});
    if (querySnapshot.docs.isNotEmpty) {
      lastDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      results = querySnapshot.docs;
    }
    isLoading = false;
    setState(() {});
  }

  loadAdditionalData() async {
    if (isLoading || !moreDataAvailable || loadingAdditionalData) {
      return;
    }
    loadingAdditionalData = true;
    setState(() {});
    Query query =
        ref.where('uid', isEqualTo: widget.currentUser.uid).orderBy('purchaseTimeInMilliseconds', descending: true).startAfterDocument(lastDocSnap).limit(20);

    QuerySnapshot querySnapshot = await query.get().catchError((e) {});
    lastDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    results.addAll(querySnapshot.docs);
    if (querySnapshot.docs.length == 0) {
      moreDataAvailable = false;
    }
    loadingAdditionalData = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadData();
    scrollController = ScrollController();
    scrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar("Redeemed Rewards", context),
      body: isLoading
          ? CustomLinearProgress(
              progressBarColor: CustomColors.webblenRed,
            )
          : Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: results.isEmpty
                  ? LiquidPullToRefresh(
                      color: CustomColors.webblenRed,
                      onRefresh: refreshData,
                      child: Center(
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Image.asset(
                                'assets/images/online_store.png',
                                height: 200,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width - 16,
                                  ),
                                  child: Text(
                                    "You Have Not Purchased Any Rewards Yet!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShopPage(currentUser: widget.currentUser))),
                                  child: Text(
                                    "Visit Shop",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: CustomColors.electronBlue),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 100.0),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return RedeemedRewardBlock(
                          data: results[index].data(),
                        );
                      }),
            ),
    );
  }
}
