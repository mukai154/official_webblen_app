import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';

class TransactionReceiptIcon extends StatelessWidget {
  final bool hasNewTransactions;
  final VoidCallback onTapAction;

  TransactionReceiptIcon({
    this.hasNewTransactions,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapAction,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 8.0,
              top: 16.0,
            ),
            child: Icon(
              FontAwesomeIcons.bars,
              size: 24.0,
              color: FlatColors.darkGray,
            ),
          ),
          Positioned(
            top: 14.0,
            left: 0.0,
            child: hasNewTransactions
                ? Container(
                    height: 12.0,
                    width: 8.0,
                    decoration: BoxDecoration(
                      color: FlatColors.webblenRed,
                      shape: BoxShape.circle,
                    ),
                  )
                : Container(
                    height: 0.0,
                    width: 0.0,
                  ),
          ),
        ],
      ),
    );
  }
}
