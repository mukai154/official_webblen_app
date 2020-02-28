import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time_calc.dart';

class TicketTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateFormat timeFormatter = DateFormat("h:mma");
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(
          left: 8.0,
          bottom: 8.0,
          right: 8.0,
        ),
        height: MediaQuery.of(context).size.width - 16,
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage("assets/images/qrcode.png"),
          //   fit: BoxFit.cover,
          // ),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/qrcode.png"),
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: 8.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    FlatColors.transparent,
                  ],
                  begin: Alignment(0.0, 0.6),
                  end: Alignment(0.0, -1.0),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Fonts().textW700(
                        'This will be the event title',
                        26.0,
                        Colors.white,
                        TextAlign.left,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Fonts().textW400(
                        TimeCalc().getWhenEventIsHappening(
                          8,
                          98,
                          timeFormatter.format(DateTime.now()),
                        ),
                        16.0,
                        Colors.white,
                        TextAlign.right,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
