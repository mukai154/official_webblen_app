import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/ui/views/wallet/shop/shop/shop_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/webblen_icon_and_balance.dart';

class ShopView extends StatelessWidget {
  Widget rewardBlock({WebblenReward reward, VoidCallback action}) {
    return GestureDetector(
      onTap: action,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: GestureDetector(
          child: Container(
            margin: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: CachedNetworkImageProvider(reward.imageURL),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/images/webblen_coin.png',
                                height: 20.0,
                                width: 20.0,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                              SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                reward.cost.toStringAsFixed(2),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget rewardsGrid(ShopViewModel model, List<DocumentSnapshot> rewards) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        WebblenReward reward = WebblenReward.fromMap(rewards[index].data());
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: rewardBlock(
            reward: reward,
            action: () => model.navigateToShopItemView(model.user, reward),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ShopViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(context),
      viewModelBuilder: () => ShopViewModel(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Scaffold(
            appBar: CustomAppBar().basicActionAppBar(
              title: "Shop",
              showBackButton: true,
              actionWidget: WebblenIconAndBalance(
                balance: model.user.WBLN,
                fontSize: 18,
              ),
            ),
            body: model.isBusy
                ? Container(
                    color: appBackgroundColor(),
                    child: Center(
                      child: CustomCircleProgressIndicator(
                        color: appActiveColor(),
                        size: 32,
                      ),
                    ),
                  )
                : Container(
                    color: appBackgroundColor(),
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        SizedBox(
                          height: 200.0,
                          width: 350.0,
                          child: Carousel(
                            boxFit: BoxFit.contain,
                            images: [
                              NetworkImage(
                                  'https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/app_images%2Fcash%20in%20.PNG?alt=media&token=9989465e-35db-4782-9e08-0fe75351569a'),
                            ],
                            dotSize: 4.0,
                            dotSpacing: 15.0,
                            showIndicator: false,
                            autoplayDuration: Duration(seconds: 5),
                            dotColor: CustomColors.webblenRed,
                            indicatorBgPadding: 5.0,
                            dotBgColor: Colors.white,
                            borderRadius: false,
                          ),
                        ),
                        //WEBBLEN MERCH
                        SizedBox(height: 16.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Webblen Merch",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: appFontColor(),
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: rewardsGrid(
                              model, model.webblenClothesRewardResults),
                        ),
                        //CASH
                        SizedBox(height: 16.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Cash Rewards",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: appFontColor(),
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: rewardsGrid(model, model.cashRewardResults),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
