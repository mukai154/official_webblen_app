import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';

class RewardCard extends StatelessWidget {
  final WebblenReward reward;
  final VoidCallback onClickAction;
  final bool purchased;

  RewardCard(this.reward, this.onClickAction, this.purchased);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onClickAction, //() => rewardClicked(index),
      child: new Container(
        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
        decoration: new BoxDecoration(
          image: DecorationImage(image: CachedNetworkImageProvider(reward.rewardImagePath), fit: BoxFit.cover),
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(16.0),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              offset: new Offset(0.0, 5.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: purchased ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
          children: <Widget>[
            purchased
                ? Container()
                : Container(
                    margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.20),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Image.asset('assets/images/webblen_coin.png', height: 20.0, width: 20.0, fit: BoxFit.contain),
                          SizedBox(width: 4.0),
                          Fonts().textW500(reward.rewardCost.toStringAsFixed(2), 12.0, FlatColors.iosOffWhite, TextAlign.left),
                        ],
                      ),
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, FlatColors.transparent],
                  begin: Alignment(0.0, 1.0),
                  end: Alignment(0.0, -1.0),
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15.0), bottomRight: Radius.circular(15.0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Fonts().textW400(reward.rewardProviderName, 12.0, FlatColors.iosOffWhite, TextAlign.left),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
