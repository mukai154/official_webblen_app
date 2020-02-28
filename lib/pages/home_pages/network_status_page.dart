import 'package:flutter/material.dart';

import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class NetworkStatusPage extends StatelessWidget {
  final VoidCallback reloadAction;

  NetworkStatusPage({
    this.reloadAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxWidth: 300,
          ),
          child: Fonts().textW500(
            "You are not connected to the Internet.",
            16.0,
            FlatColors.darkGray,
            TextAlign.center,
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        CustomColorButton(
          text: 'Try Again',
          textColor: FlatColors.darkGray,
          backgroundColor: Colors.white,
          height: 45.0,
          width: 100.0,
          hPadding: 16.0,
          onPressed: reloadAction,
        ),
      ],
    );
  }
}
