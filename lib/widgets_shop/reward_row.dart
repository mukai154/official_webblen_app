import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/styles/flat_colors.dart';

class RewardRow extends StatelessWidget {

  final WebblenReward reward;
  final VoidCallback callbackAction;
  final TextStyle headerTextStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0, color: FlatColors.blackPearl);
  final TextStyle subHeaderTextStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, color: FlatColors.londonSquare);
  final TextStyle bodyTextStyle =  TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: FlatColors.blackPearl);
  final TextStyle pointStatStyle =  TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: FlatColors.londonSquare);
  final TextStyle eventStatStyle =  TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: FlatColors.londonSquare);

  RewardRow(this.reward, this.callbackAction);

  @override
  Widget build(BuildContext context) {

    final rewardPic = new ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: FadeInImage.assetNetwork(placeholder: "assets/gifs/loading.gif", image: reward.rewardImagePath, width: 60.0),
    );

    final rewardPicContainer = new Container(
      margin: new EdgeInsets.symmetric(vertical: 0.0),
      alignment: FractionalOffset.topLeft,
      child: rewardPic,
    );

    Widget rewardCost() {
      return new Row(
          children: <Widget>[
            new Icon(Icons.attach_money, size: 18.0, color: FlatColors.vibrantYellow,),
            new Container(width: 8.0),
            new Text(reward.rewardCost.toString(), style: pointStatStyle),
          ]
      );
    }

    Widget numberAvailable() {
      return new Row(
          children: <Widget>[
            new Text("Available:", style: eventStatStyle),
            new Container(width: 8.0),
            new Text(reward.amountAvailable.toString(), style: eventStatStyle),
          ]
      );
    }

    final rewardCardContent = new Container(
      margin: new EdgeInsets.fromLTRB(45.0, 6.0, 14.0, 6.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(height: 8.0),
          new Text(reward.rewardProviderName, style: headerTextStyle),
          SizedBox(height: 8.0),
          new Text(reward.rewardDescription, style: subHeaderTextStyle),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              rewardCost(),
              new Container(width: 28.0,),
              numberAvailable(),
              new Container(width: 4.0,)
            ],
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );

    final rewardCard = new Container(
//      height: eventPost.pathToImage == "" ? 185.0 : 440.0,
      margin: new EdgeInsets.fromLTRB(24.0, 6.0, 8.0, 8.0),
      child: rewardCardContent,
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: new Offset(0.0, 10.0),
          ),
        ],
      ),

    );


    return new GestureDetector(
      onTap: () => callbackAction,
      child: new Container(
          margin: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          child: new Stack(
            children: <Widget>[
              rewardCard,
              rewardPicContainer,
            ],
          )
      ),
    );
  }

}