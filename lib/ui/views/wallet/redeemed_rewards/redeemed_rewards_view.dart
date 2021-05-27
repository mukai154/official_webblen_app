import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/enums/reward_status.dart';
import 'package:webblen/enums/reward_type.dart';
import 'package:webblen/models/webblen_redeemed_reward.dart';
import 'package:webblen/ui/views/wallet/redeemed_rewards/redeemed_rewards_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/utils/time_calc.dart';

class RedeemedRewardsView extends StatelessWidget {
  Widget statusIndicator(WebblenRedeemedReward redeemedReward) {
    return Icon(
      FontAwesomeIcons.solidCircle,
      size: 12.0,
      color: redeemedReward.rewardStatus == RewardStatus.pending
          ? CustomColors.turboYellow
          : redeemedReward.rewardStatus == RewardStatus.complete
              ? CustomColors.darkMountainGreen
              : Colors.red,
    );
  }

  Widget merchBlock(WebblenRedeemedReward redeemedReward) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                redeemedReward.rewardStatus == RewardStatus.complete ? 'Complete' : 'Pending',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4.0),
              statusIndicator(redeemedReward),
            ],
          ),
          Row(
            children: [
              Text(
                "${redeemedReward.rewardTitle} | Size: ${redeemedReward.clothingSize.toString()}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                TimeCalc().getPastTimeFromMilliseconds(
                  redeemedReward.purchaseTimeInMilliseconds!,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget cashBlock(WebblenRedeemedReward redeemedReward) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              statusIndicator(redeemedReward),
            ],
          ),
          Row(
            children: [
              Text(
                "${redeemedReward.rewardTitle} | receiver: ${redeemedReward.uid}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                TimeCalc().getPastTimeFromMilliseconds(
                  redeemedReward.purchaseTimeInMilliseconds!,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RedeemedRewardsViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(context),
      viewModelBuilder: () => RedeemedRewardsViewModel(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Scaffold(
            appBar: CustomAppBar().basicAppBar(
              title: "Redeemed Rewards",
              showBackButton: true,
            ) as PreferredSizeWidget?,
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
                    height: MediaQuery.of(context).size.height,
                    child: model.redeemedRewardResults.isEmpty
                        ? LiquidPullToRefresh(
                            onRefresh: () => model.refreshRedeemedRewards(context),
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
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      // GestureDetector(
                                      // onTap: () => Navigator.pushReplacement(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => ShopPage(
                                      //       currentUser: widget.currentUser,
                                      //     ),
                                      //   ),
                                      // ),
                                      // child:
                                      Text(
                                        "Visit Shop",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w700,
                                          color: appTextButtonColor(),
                                        ),
                                      ),
                                      // ),
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
                            itemCount: model.redeemedRewardResults.length,
                            itemBuilder: (context, index) {
                              WebblenRedeemedReward redeemedReward = WebblenRedeemedReward.fromMap(
                                model.redeemedRewardResults[index].data()!,
                              );
                              return redeemedReward.rewardType == RewardType.webblenClothes ? merchBlock(redeemedReward) : cashBlock(redeemedReward);
                            },
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}
