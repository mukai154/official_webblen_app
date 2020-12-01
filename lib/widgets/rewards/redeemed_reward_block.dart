import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/utils/time_calc.dart';

class RedeemedRewardBlock extends StatelessWidget {
  final Map<String, dynamic> data;

  RedeemedRewardBlock({
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    final statusIndicator = Icon(
      FontAwesomeIcons.solidCircle,
      size: 12.0,
      color: data['status'] == 'pending'
          ? FlatColors.vibrantYellow
          : data['status'] == 'approved' || data['status'] == 'complete'
              ? FlatColors.lightCarribeanGreen
              : Colors.red,
    );

    final merchBlock = Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                data['status'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
              ),
              SizedBox(width: 4.0),
              statusIndicator,
            ],
          ),
          Row(
            children: [
              Text(
                "${data['rewardTitle']} | Size: ${data['size']}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                TimeCalc().getPastTimeFromMilliseconds(data['purchaseTimeInMilliseconds']),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0, color: Colors.black45, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );

    final cashBlock = Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              statusIndicator,
            ],
          ),
          Row(
            children: [
              Text(
                "${data['rewardTitle']} | receiver: ${data['username']}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                TimeCalc().getPastTimeFromMilliseconds(data['purchaseTimeInMilliseconds']),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );

    return data['rewardType'] == "webblenClothes" ? merchBlock : cashBlock;
  }
}
