import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:webblen/styles/flat_colors.dart';

class AttendancePowerBar extends StatelessWidget {
  final double currentAP;
  final int apLvl;

  AttendancePowerBar({
    this.currentAP,
    this.apLvl,
  });

  final barHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: MediaQuery.of(context).size.width - 16.0,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Shimmer.fromColors(
                      baseColor: currentAP > 0.05
                          ? FlatColors.darkMountainGreen
                          : FlatColors.webblenRed,
                      highlightColor: currentAP > 0.05
                          ? FlatColors.lightCarribeanGreen
                          : FlatColors.firstDate,
                      child: Container(
                        height: barHeight,
                        width: (MediaQuery.of(context).size.width - 32) *
                            currentAP,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: barHeight * 0.25,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(),
                Container(
                  height: barHeight / 2,
                  width: 2.0,
                  color: Colors.black26,
                ),
                Container(
                  height: barHeight / 2,
                  width: 2.0,
                  color: Colors.black26,
                ),
                Container(
                  height: barHeight / 2,
                  width: 2.0,
                  color: Colors.black26,
                ),
                Container(
                  height: barHeight / 2,
                  width: 2.0,
                  color: Colors.black26,
                ),
                Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmallAttendancePowerBar extends StatelessWidget {
  final double currentAP;
  final int apLvl;

  SmallAttendancePowerBar({
    this.currentAP,
    this.apLvl,
  });

  final double barHeight = 10.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.0,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Shimmer.fromColors(
                      baseColor: currentAP > 0.05
                          ? FlatColors.darkMountainGreen
                          : FlatColors.webblenRed,
                      highlightColor: currentAP > 0.05
                          ? FlatColors.lightCarribeanGreen
                          : FlatColors.firstDate,
                      child: Container(
                        height: barHeight,
                        width: 200 * currentAP,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: barHeight * 0.25,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(),
                Container(
                  height: barHeight / 2,
                  width: 2.0,
                  color: Colors.black26,
                ),
                Container(
                  height: barHeight / 2,
                  width: 2.0,
                  color: Colors.black26,
                ),
                Container(
                  height: barHeight / 2,
                  width: 2.0,
                  color: Colors.black26,
                ),
                Container(
                  height: barHeight / 2,
                  width: 2.0,
                  color: Colors.black26,
                ),
                Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MiniAttendancePowerBar extends StatelessWidget {
  final double currentAP;
  final int apLvl;

  MiniAttendancePowerBar({
    this.currentAP,
    this.apLvl,
  });

  final double barHeight = 8.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Shimmer.fromColors(
                      baseColor: currentAP > 0.05
                          ? FlatColors.darkMountainGreen
                          : FlatColors.webblenRed,
                      highlightColor: currentAP > 0.05
                          ? FlatColors.lightCarribeanGreen
                          : FlatColors.firstDate,
                      child: Container(
                        height: barHeight,
                        width: 100 * currentAP,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
