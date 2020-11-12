import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/styles/flat_colors.dart';

class RewardRow extends StatelessWidget {
  final WebblenReward reward;
  final VoidCallback callbackAction;
  final TextStyle headerTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
    color: FlatColors.blackPearl,
  );
  final TextStyle subHeaderTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: FlatColors.londonSquare,
  );
  final TextStyle bodyTextStyle = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    color: FlatColors.blackPearl,
  );
  final TextStyle pointStatStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: FlatColors.londonSquare,
  );
  final TextStyle eventStatStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: FlatColors.londonSquare,
  );

  RewardRow(
    this.reward,
    this.callbackAction,
  );

  @override
  Widget build(BuildContext context) {
    final rewardPic = ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: FadeInImage.assetNetwork(placeholder: "assets/gifs/loading.gif", image: reward.imageURL, width: 60.0),
    );

    final rewardPicContainer = Container(
      margin: EdgeInsets.symmetric(
        vertical: 0.0,
      ),
      alignment: FractionalOffset.topLeft,
      child: rewardPic,
    );

    Widget rewardCost() {
      return Row(
        children: <Widget>[
          Icon(
            Icons.attach_money,
            size: 18.0,
            color: FlatColors.vibrantYellow,
          ),
          Container(width: 8.0),
          Text(
            reward.cost.toString(),
            style: pointStatStyle,
          ),
        ],
      );
    }

    Widget numberAvailable() {
      return Row(
        children: <Widget>[
          Text(
            "Available:",
            style: eventStatStyle,
          ),
          Container(width: 8.0),
          Text(
            reward.amountAvailable.toString(),
            style: eventStatStyle,
          ),
        ],
      );
    }

    final rewardCardContent = Container(
      margin: EdgeInsets.fromLTRB(45.0, 6.0, 14.0, 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 8.0,
          ),
          Text(
            reward.title,
            style: headerTextStyle,
          ),
          SizedBox(height: 8.0),
          Text(
            reward.description,
            style: subHeaderTextStyle,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              rewardCost(),
              Container(
                width: 28.0,
              ),
              numberAvailable(),
              Container(
                width: 4.0,
              )
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
        ],
      ),
    );

    final rewardCard = Container(
//      height: eventPost.pathToImage == "" ? 185.0 : 440.0,
      margin: EdgeInsets.fromLTRB(24.0, 6.0, 8.0, 8.0),
      child: rewardCardContent,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => callbackAction,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        child: Stack(
          children: <Widget>[
            rewardCard,
            rewardPicContainer,
          ],
        ),
      ),
    );
  }
}
